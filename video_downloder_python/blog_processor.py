"""
Blog Processor — fetch, clean, and AI-rewrite blog content.

Supports two AI backends:
  - "local"  → Ollama (http://localhost:11434)
  - "gemini" → Google Gemini REST API
"""

import json
import logging
import re
import time
from typing import Any, Dict, List, Optional

import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "llama3"

GEMINI_API_KEY = ""  # Set via env or override before calling
GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-2.0-flash:generateContent"
)

AI_PROMPT_TEMPLATE = """You are a professional blog rewriter. Rewrite the following blog content and return ONLY valid JSON (no markdown, no explanation, no code fences).

The JSON must have these exact keys:
{{
  "title": "SEO-friendly English title",
  "titleHindi": "Hindi translation of title",
  "description": "Full rewritten HTML blog content wrapped in <p> tags",
  "descriptionHindi": "Hindi translation of full content in <p> tags",
  "summary": "2-3 sentence English summary",
  "summaryHindi": "Hindi translation of summary",
  "keywords": "comma separated English keywords",
  "keywordHindi": "comma separated Hindi keywords",
  "content": "Plain text version of the rewritten content"
}}

Blog Title: {title}

Blog Content:
{content}
"""

MAX_RETRIES = 1


class BlogProcessError(Exception):
    """Raised when blog processing fails."""


# ---------------------------------------------------------------------------
# Step 1: Fetch & extract blog content
# ---------------------------------------------------------------------------
def fetch_blog_content(url: str) -> Dict[str, str]:
    """Fetch blog HTML, extract title and main text content."""
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
        ),
    }

    try:
        resp = requests.get(url, headers=headers, timeout=30)
        resp.raise_for_status()
    except requests.RequestException as exc:
        raise BlogProcessError(f"Failed to fetch blog URL: {exc}") from exc

    html = resp.text
    soup = BeautifulSoup(html, "html.parser")

    # Remove noise elements
    for tag in soup.find_all(["script", "style", "nav", "footer", "header", "aside", "iframe", "noscript"]):
        tag.decompose()

    # Remove common ad/sidebar classes
    for selector in [".ad", ".ads", ".sidebar", ".navigation", ".menu", ".cookie", ".popup", ".banner"]:
        for el in soup.select(selector):
            el.decompose()

    # Extract title
    title = ""
    og_title = soup.find("meta", attrs={"property": "og:title"})
    if og_title and og_title.get("content"):
        title = og_title["content"]
    elif soup.title and soup.title.string:
        title = soup.title.string.strip()
    elif soup.find("h1"):
        title = soup.find("h1").get_text(strip=True)

    # Extract main content — prefer <article>, then <main>, then <body>
    content_el = soup.find("article") or soup.find("main") or soup.find("body")
    if not content_el:
        raise BlogProcessError("Could not find any content in the blog page.")

    # Get paragraphs
    paragraphs = content_el.find_all("p")
    text_parts = [p.get_text(strip=True) for p in paragraphs if p.get_text(strip=True)]

    if not text_parts:
        # Fallback: get all text
        text_parts = [content_el.get_text(separator="\n", strip=True)]

    content = "\n\n".join(text_parts)

    # Trim to ~4000 chars to stay within AI token limits
    if len(content) > 4000:
        content = content[:4000] + "..."

    logger.info("Extracted blog: title=%s, content_length=%d", title[:50], len(content))
    return {"title": title, "content": content}


# ---------------------------------------------------------------------------
# Step 2: AI processing
# ---------------------------------------------------------------------------
def _build_prompt(title: str, content: str) -> str:
    return AI_PROMPT_TEMPLATE.format(title=title, content=content)


def _parse_ai_json(raw: str) -> Dict[str, Any]:
    """Extract JSON from AI response, handling markdown fences."""
    # Strip markdown code fences if present
    cleaned = re.sub(r"^```(?:json)?\s*", "", raw.strip())
    cleaned = re.sub(r"\s*```$", "", cleaned)

    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        # Try to find JSON object in the text
        match = re.search(r"\{[\s\S]*\}", cleaned)
        if match:
            return json.loads(match.group())
        raise BlogProcessError(f"AI returned invalid JSON: {raw[:300]}")


def process_with_ollama(title: str, content: str) -> Dict[str, Any]:
    """Send content to local Ollama and get structured JSON back."""
    prompt = _build_prompt(title, content)

    payload = {
        "model": OLLAMA_MODEL,
        "prompt": prompt,
        "stream": False,
    }

    for attempt in range(MAX_RETRIES + 1):
        try:
            logger.info("Ollama request (attempt %d)", attempt + 1)
            resp = requests.post(OLLAMA_URL, json=payload, timeout=300)
            resp.raise_for_status()

            body = resp.json()
            raw_response = body.get("response", "")
            logger.info("Ollama raw response length: %d", len(raw_response))

            return _parse_ai_json(raw_response)

        except (requests.RequestException, BlogProcessError, json.JSONDecodeError) as exc:
            logger.warning("Ollama attempt %d failed: %s", attempt + 1, exc)
            if attempt >= MAX_RETRIES:
                raise BlogProcessError(f"Ollama processing failed after retries: {exc}") from exc
            time.sleep(2)

    raise BlogProcessError("Ollama processing failed unexpectedly")


def process_with_gemini(title: str, content: str, api_key: str) -> Dict[str, Any]:
    """Send content to Gemini API and get structured JSON back."""
    prompt = _build_prompt(title, content)

    url = f"{GEMINI_URL}?key={api_key}"
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.7,
            "responseMimeType": "application/json",
        },
    }

    for attempt in range(MAX_RETRIES + 1):
        try:
            logger.info("Gemini request (attempt %d)", attempt + 1)
            resp = requests.post(url, json=payload, timeout=120)
            resp.raise_for_status()

            body = resp.json()
            candidates = body.get("candidates", [])
            if not candidates:
                raise BlogProcessError("Gemini returned no candidates")

            raw_text = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "")
            logger.info("Gemini raw response length: %d", len(raw_text))

            return _parse_ai_json(raw_text)

        except (requests.RequestException, BlogProcessError, json.JSONDecodeError) as exc:
            logger.warning("Gemini attempt %d failed: %s", attempt + 1, exc)
            if attempt >= MAX_RETRIES:
                raise BlogProcessError(f"Gemini processing failed after retries: {exc}") from exc
            time.sleep(2)

    raise BlogProcessError("Gemini processing failed unexpectedly")


# ---------------------------------------------------------------------------
# Step 3: Transform to final response format
# ---------------------------------------------------------------------------
def _slugify(text: str) -> str:
    """Simple slug generator."""
    slug = text.lower().strip()
    slug = re.sub(r"[^\w\s-]", "", slug)
    slug = re.sub(r"[\s_]+", "-", slug)
    slug = re.sub(r"-+", "-", slug).strip("-")
    return slug[:100]


def build_final_response(
    ai_data: Dict[str, Any],
    category_id: int,
    tags: List[int],
) -> Dict[str, Any]:
    """Transform AI output into the final API response format."""
    title = ai_data.get("title", "")
    slug = _slugify(title) if title else ""

    return {
        "success": True,
        "data": {
            "title": title,
            "titleHindi": ai_data.get("titleHindi", ""),
            "articleType": category_id,
            "slugUrl": slug,
            "keywords": ai_data.get("keywords", ""),
            "keywordHindi": ai_data.get("keywordHindi", ""),
            "description": ai_data.get("description", ""),
            "descriptionHindi": ai_data.get("descriptionHindi", ""),
            "summary": ai_data.get("summary", ""),
            "summaryHindi": ai_data.get("summaryHindi", ""),
            "thumbnail": "",
            "thumbnailCredit": None,
            "articleFaqsDTOs": [],
            "articleTagsDTOs": tags,
            "descriptionJson": "{}",
            "descriptionJsonHindi": "{}",
        },
    }


# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------
def process_blog(
    url: str,
    mode: str = "local",
    category_id: int = 0,
    tags: Optional[List[int]] = None,
    gemini_api_key: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Full pipeline: fetch blog -> extract content -> AI rewrite -> structured response.
    """
    if tags is None:
        tags = []

    # Step 1: Fetch & extract
    blog_data = fetch_blog_content(url)
    title = blog_data["title"]
    content = blog_data["content"]

    if not content.strip():
        raise BlogProcessError("No meaningful content found in the blog.")

    # Step 2: AI processing
    if mode == "gemini":
        key = gemini_api_key or GEMINI_API_KEY
        if not key:
            raise BlogProcessError("Gemini API key is required for mode='gemini'")
        ai_data = process_with_gemini(title, content, key)
    else:
        ai_data = process_with_ollama(title, content)

    # Step 3: Build final response
    return build_final_response(ai_data, category_id, tags)
