"""
Blog Processor — fetch, clean, and AI-rewrite blog content.

Supports two AI backends:
  - "local"  → Ollama (http://localhost:11434) with model fallback
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
OLLAMA_BASE_URL = "http://localhost:11434"
OLLAMA_GENERATE_URL = f"{OLLAMA_BASE_URL}/api/generate"

# Models to try in order — first success wins
OLLAMA_MODELS = ["llama3", "llama3.1:8b", "mistral", "gemma2"]

GEMINI_API_KEY = ""  # Set via env or override before calling
GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-2.0-flash:generateContent"
)

MAX_RETRIES = 1
CONTENT_CHAR_LIMIT = 15000


class BlogProcessError(Exception):
    """Raised when blog processing fails."""


# ---------------------------------------------------------------------------
# Ollama health / model discovery
# ---------------------------------------------------------------------------
def check_ollama_running() -> bool:
    """Check if Ollama server is running."""
    try:
        resp = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=5)
        return resp.status_code == 200
    except requests.ConnectionError:
        return False


def get_available_models() -> List[str]:
    """Get list of locally available Ollama models."""
    try:
        resp = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=5)
        if resp.status_code == 200:
            data = resp.json()
            return [m["name"] for m in data.get("models", [])]
    except Exception:
        pass
    return []


# ---------------------------------------------------------------------------
# Prompt builder
# ---------------------------------------------------------------------------
def _build_prompt(
    scraped_text: str,
    source_url: str,
    category_id: int = 0,
    tags: Optional[List[int]] = None,
) -> str:
    tag_ids = tags or []

    return f"""You are a professional bilingual (English + Hindi) blog writer and SEO expert.

I will give you scraped text from a blog URL. Rewrite it into a fresh, original, SEO-friendly blog post in BOTH English and Hindi.

Source URL: {source_url}

Scraped content:
{scraped_text}

You MUST respond with ONLY valid JSON (no markdown fences, no extra text). Use this exact structure:

{{
"title": "English blog title",
"titleHindi": "Hindi blog title",
"articleType": {category_id},
"slugUrl": "english-title-as-slug",
"keywords": "keyword1, keyword2, keyword3",
"keywordHindi": "hindi keyword1, hindi keyword2",
"description": "<p>Full rewritten English blog as HTML with <p> and <h2> tags</p>",
"descriptionHindi": "<p>Full rewritten Hindi blog as HTML with <p> and <h2> tags</p>",
"summary": "2-3 sentence English summary",
"summaryHindi": "2-3 sentence Hindi summary",
"thumbnail": "",
"thumbnailCredit": null,
"articleFaqsDTOs": [
{{
"id": 0,
"que": "English question about a key topic from the blog",
"ans": "English answer explaining the topic clearly",
"queHindi": "Same question in Hindi",
"ansHindi": "Same answer in Hindi",
"isUpdate": false
}}
],
"articleTagsDTOs": {tag_ids},
"descriptionJson": "{{}}",
"descriptionJsonHindi": "{{}}"
}}

Rules:
-The English description must be well-structured HTML with <h2> headings and <p> paragraphs
-The Hindi description must be a faithful translation, also in HTML format
-keywords should be 5-8 comma-separated relevant SEO keywords
-slugUrl must be lowercase, hyphen-separated, no special characters
-summary should be concise, 2-3 sentences
-Respond with ONLY the JSON object, nothing else
-Change Website name, if getting other same just replace with PreptTM
-Total word limit for description and descriptionHindi combined should not exceed 800+ words
-Generate 3-5 FAQs in articleFaqsDTOs based on the blog content
-Each FAQ must have que/ans in English and queHindi/ansHindi in Hindi
-Use id:0 and isUpdate:false for all FAQs
-Tables MUST be wrapped like: <div class="editor-table"><table><tbody><tr><td>cell</td></tr></tbody></table></div>
-Add at least one HTML table wherever helpful for easy understanding
-Blog content must feel natural and human-written
-Completely rewrite the content; do NOT copy from source
-Keep language simple and easy to understand
-Hindi content should be natural and conversational
-Use common English words in Hindi where appropriate (app, online, process)
-Add govt links if found (.gov, .nic.in, .org) with anchor tags
"""


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

    # Get full text with structure preserved
    content = content_el.get_text(separator="\n", strip=True)

    if len(content) > CONTENT_CHAR_LIMIT:
        content = content[:CONTENT_CHAR_LIMIT]

    logger.info("Extracted blog: title=%s, content_length=%d", title[:50], len(content))
    return {"title": title, "content": content}


# ---------------------------------------------------------------------------
# Step 2: AI processing
# ---------------------------------------------------------------------------
def _parse_ai_json(raw: str) -> Dict[str, Any]:
    """Extract JSON from AI response, handling markdown fences."""
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.split("\n", 1)[1] if "\n" in cleaned else cleaned[3:]
    if cleaned.endswith("```"):
        cleaned = cleaned[:-3]
    cleaned = cleaned.strip()

    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        # Try to find JSON object in the text
        match = re.search(r"\{[\s\S]*\}", cleaned)
        if match:
            return json.loads(match.group())
        raise BlogProcessError(f"AI returned invalid JSON: {raw[:300]}")


def process_with_ollama(
    scraped_text: str,
    source_url: str,
    category_id: int = 0,
    tags: Optional[List[int]] = None,
    model: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Send content to local Ollama with model fallback.
    Tries each model in OLLAMA_MODELS until one succeeds.
    """
    if not check_ollama_running():
        raise BlogProcessError("Ollama is not running. Start it with: ollama serve")

    prompt = _build_prompt(scraped_text, source_url, category_id, tags)

    available = get_available_models()
    # Strip ":latest" suffix for matching (e.g. "llama3:latest" matches "llama3")
    available_base = {m.split(":")[0] for m in available} | set(available)
    if model:
        models_to_try = [model]
    else:
        models_to_try = [m for m in OLLAMA_MODELS if m in available_base]

    if not models_to_try:
        raise BlogProcessError(
            f"No Ollama models available. Installed: {available}. "
            f"Expected one of: {OLLAMA_MODELS}"
        )

    last_error = None

    for i, m in enumerate(models_to_try):
        logger.info("[Ollama] Trying model %d/%d: %s", i + 1, len(models_to_try), m)
        try:
            resp = requests.post(
                OLLAMA_GENERATE_URL,
                json={
                    "model": m,
                    "prompt": prompt,
                    "stream": False,
                    "format": "json",
                    "options": {
                        "temperature": 0.7,
                        "num_predict": 4096,
                    },
                },
                timeout=600,  # 10 min — local models can be slow with large content
            )

            if resp.status_code != 200:
                logger.warning("[Ollama] Model %s failed: HTTP %s", m, resp.status_code)
                last_error = f"Model {m}: HTTP {resp.status_code}"
                continue

            data = resp.json()
            raw_response = data.get("response", "")

            if not raw_response.strip():
                logger.warning("[Ollama] Model %s returned empty response", m)
                last_error = f"Model {m}: empty response"
                continue

            logger.info("[Ollama] Model %s succeeded (%d chars)", m, len(raw_response))
            return _parse_ai_json(raw_response)

        except requests.Timeout:
            logger.warning("[Ollama] Model %s timed out", m)
            last_error = f"Model {m}: timeout"
            continue
        except BlogProcessError:
            raise
        except Exception as exc:
            logger.warning("[Ollama] Model %s error: %s", m, exc)
            last_error = str(exc)
            continue

    raise BlogProcessError(f"All Ollama models failed. Last error: {last_error}")


def process_with_gemini(
    scraped_text: str,
    source_url: str,
    category_id: int = 0,
    tags: Optional[List[int]] = None,
    api_key: str = "",
) -> Dict[str, Any]:
    """Send content to Gemini API and get structured JSON back."""
    prompt = _build_prompt(scraped_text, source_url, category_id, tags)

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

    # Trim content for local mode — llama3 8B is slow with very large input
    if mode == "local" and len(content) > 5000:
        content = content[:5000]
        logger.info("Trimmed content to 5000 chars for local mode")

    # Step 2: AI processing — returns the full response directly from AI
    if mode == "gemini":
        key = gemini_api_key or GEMINI_API_KEY
        if not key:
            raise BlogProcessError("Gemini API key is required for mode='gemini'")
        ai_data = process_with_gemini(content, url, category_id, tags, key)
    else:
        ai_data = process_with_ollama(content, url, category_id, tags)

    # The AI response already matches the final format from the prompt
    return {"success": True, "data": ai_data}
