# Ollama Python Integration for Blog Generation

## Overview

When Flutter sends `mode: "local"` to `POST /process-blog`, the Python server uses Ollama (local LLM) instead of Gemini to rewrite the blog.

---

## Prerequisites

### 1. Install Ollama

```bash
# Windows — download from https://ollama.com/download
# Linux
curl -fsSL https://ollama.com/install.sh | sh
# macOS
brew install ollama
```

### 2. Pull a Model

```bash
ollama pull llama3
# or for better quality (needs more RAM)
ollama pull llama3.1:8b
```

### 3. Start Ollama Server

```bash
ollama serve
# Runs at http://localhost:11434
```

Verify it's running:
```bash
curl http://localhost:11434/api/tags
```

---

## Ollama API Reference

### Endpoint

```
POST http://localhost:11434/api/generate
```

### Request Body

```json
{
  "model": "llama3",
  "prompt": "Your prompt here",
  "stream": false,
  "format": "json",
  "options": {
    "temperature": 0.7,
    "num_predict": 4096
  }
}
```

### Response

```json
{
  "model": "llama3",
  "response": "{ ... JSON string ... }",
  "done": true,
  "total_duration": 12345678
}
```

The `response` field contains the LLM's text output. With `"format": "json"` the model is forced to output valid JSON.

---

## Python Implementation

### 1. Install Dependencies

```bash
pip install requests beautifulsoup4 fastapi uvicorn
```

### 2. Ollama Service (`ollama_service.py`)

```python
import requests
import json
import time

OLLAMA_BASE_URL = "http://localhost:11434"

# Models to try in order — first success wins
OLLAMA_MODELS = [
    "llama3",
    "llama3.1:8b",
    "mistral",
    "gemma2",
]


def check_ollama_running():
    """Check if Ollama server is running."""
    try:
        resp = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=5)
        return resp.status_code == 200
    except requests.ConnectionError:
        return False


def get_available_models():
    """Get list of locally available models."""
    try:
        resp = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=5)
        if resp.status_code == 200:
            data = resp.json()
            return [m["name"] for m in data.get("models", [])]
    except Exception:
        pass
    return []


def generate_with_ollama(prompt: str, model: str = None) -> str:
    """
    Call Ollama API with model fallback.
    Tries each model in OLLAMA_MODELS until one succeeds.
    Returns the raw response text.
    """
    available = get_available_models()
    models_to_try = [model] if model else [m for m in OLLAMA_MODELS if m in available]

    if not models_to_try:
        raise Exception(
            f"No Ollama models available. Installed: {available}. "
            f"Expected one of: {OLLAMA_MODELS}"
        )

    last_error = None

    for i, m in enumerate(models_to_try):
        print(f"[Ollama] Trying model {i+1}/{len(models_to_try)}: {m}")
        try:
            resp = requests.post(
                f"{OLLAMA_BASE_URL}/api/generate",
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
                timeout=300,  # 5 min — local models can be slow
            )

            if resp.status_code != 200:
                print(f"[Ollama] Model {m} failed: HTTP {resp.status_code}")
                last_error = f"Model {m}: HTTP {resp.status_code}"
                continue

            data = resp.json()
            response_text = data.get("response", "")

            if not response_text.strip():
                print(f"[Ollama] Model {m} returned empty response")
                last_error = f"Model {m}: empty response"
                continue

            print(f"[Ollama] Model {m} succeeded ({len(response_text)} chars)")
            return response_text

        except requests.Timeout:
            print(f"[Ollama] Model {m} timed out")
            last_error = f"Model {m}: timeout"
            continue
        except Exception as e:
            print(f"[Ollama] Model {m} error: {e}")
            last_error = str(e)
            continue

    raise Exception(f"All Ollama models failed. Last error: {last_error}")
```

### 3. Blog Scraper (`scraper.py`)

```python
import requests
from bs4 import BeautifulSoup


def scrape_blog(url: str) -> str:
    """Fetch and extract text content from a blog URL."""
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/120.0.0.0 Safari/537.36"
        )
    }

    resp = requests.get(url, headers=headers, timeout=30)
    resp.raise_for_status()

    soup = BeautifulSoup(resp.text, "html.parser")

    # Remove unwanted elements
    for tag in soup(["script", "style", "nav", "footer", "header", "aside", "iframe"]):
        tag.decompose()

    # Try article/main content first, fallback to body
    content = soup.find("article") or soup.find("main") or soup.find("body")
    if not content:
        return ""

    text = content.get_text(separator="\n", strip=True)

    # Limit to ~15000 chars
    if len(text) > 15000:
        text = text[:15000]

    return text
```

### 4. Prompt Builder (`prompt_builder.py`)

```python
def build_blog_prompt(scraped_text: str, source_url: str, category_id: int = 0, tags: list = None) -> str:
    """Build the same prompt used by the Gemini flow."""
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
```

### 5. FastAPI Server (`main.py`)

```python
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from scraper import scrape_blog
from prompt_builder import build_blog_prompt
from ollama_service import generate_with_ollama, check_ollama_running

# -- For Gemini mode (if you also want Gemini in the same server) --
# from gemini_service import generate_with_gemini

app = FastAPI(title="Blog Generator API")


class ProcessBlogRequest(BaseModel):
    url: str
    mode: str = "local"  # "local" (Ollama) or "gemini"
    category_id: int = 0
    tags: List[int] = []
    gemini_api_key: Optional[str] = None


@app.post("/process-blog")
async def process_blog(req: ProcessBlogRequest):
    """
    1. Scrape the blog URL
    2. Build the prompt
    3. Call Ollama (local) or Gemini
    4. Parse and return the JSON response
    """
    # Validate
    if not req.url.strip():
        raise HTTPException(400, detail="URL is required")

    # Step 1: Scrape
    try:
        scraped_text = scrape_blog(req.url)
    except Exception as e:
        return {"success": False, "message": f"Failed to scrape URL: {e}"}

    if not scraped_text.strip():
        return {"success": False, "message": "Could not extract content from the URL"}

    # Step 2: Build prompt
    prompt = build_blog_prompt(
        scraped_text=scraped_text,
        source_url=req.url,
        category_id=req.category_id,
        tags=req.tags,
    )

    # Step 3: Generate
    try:
        if req.mode == "local":
            if not check_ollama_running():
                return {
                    "success": False,
                    "message": "Ollama is not running. Start it with: ollama serve",
                }
            raw_response = generate_with_ollama(prompt)

        elif req.mode == "gemini":
            if not req.gemini_api_key:
                return {
                    "success": False,
                    "message": "Gemini API key is required for gemini mode",
                }
            # raw_response = generate_with_gemini(prompt, req.gemini_api_key)
            return {"success": False, "message": "Gemini mode not implemented in this server"}

        else:
            return {"success": False, "message": f"Unknown mode: {req.mode}"}

    except Exception as e:
        return {"success": False, "message": f"AI generation failed: {e}"}

    # Step 4: Parse JSON response
    try:
        # Clean markdown fences if present
        text = raw_response.strip()
        if text.startswith("```"):
            text = text.split("\n", 1)[1] if "\n" in text else text[3:]
        if text.endswith("```"):
            text = text[:-3]
        text = text.strip()

        blog_data = json.loads(text)
        return {"success": True, "data": blog_data}

    except json.JSONDecodeError as e:
        print(f"[Error] Failed to parse AI response as JSON: {e}")
        print(f"[Error] Raw response: {raw_response[:500]}")
        return {
            "success": False,
            "message": "AI returned invalid JSON. Try again.",
        }


@app.get("/health")
async def health():
    ollama_ok = check_ollama_running()
    return {
        "status": "ok",
        "ollama": "running" if ollama_ok else "not running",
    }
```

### 6. Run the Server

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## Project Structure

```
python-blog-api/
├── main.py               # FastAPI server with /process-blog endpoint
├── ollama_service.py     # Ollama API client with model fallback
├── scraper.py            # Blog URL scraper (BeautifulSoup)
├── prompt_builder.py     # Shared prompt builder (same as Flutter/Gemini)
├── requirements.txt      # Dependencies
```

### `requirements.txt`

```
fastapi>=0.104.0
uvicorn>=0.24.0
requests>=2.31.0
beautifulsoup4>=4.12.0
pydantic>=2.0.0
```

Install:
```bash
pip install -r requirements.txt
```

---

## Flutter ↔ Python Flow

```
Flutter App                          Python Server (port 8000)
-----------                          -------------------------
1. User enters URL
2. Selects mode = "local"
3. Selects category + tags
4. Taps "Generate Blog"
         |
         |  POST /process-blog
         |  { url, mode: "local", category_id, tags }
         └──────────────────────────────►
                                          5. Scrape URL (requests + BS4)
                                          6. Build prompt
                                          7. Call Ollama (localhost:11434)
                                             → Try llama3 first
                                             → Fallback to next model
                                          8. Parse JSON response
         ◄──────────────────────────────┐
         |  { success: true, data: {...} }
         |
9. Show preview (editable)
10. User taps "Publish"
```

---

## cURL Test

```bash
# Health check
curl http://localhost:8000/health

# Generate blog (local mode)
curl -X POST http://localhost:8000/process-blog \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/blog-post",
    "mode": "local",
    "category_id": 53,
    "tags": [13, 6, 21]
  }'
```

---

## Ollama Useful Commands

```bash
# List installed models
ollama list

# Pull a model
ollama pull llama3
ollama pull llama3.1:8b
ollama pull mistral

# Run model interactively (for testing)
ollama run llama3

# Check running models
ollama ps

# Start server (if not auto-started)
ollama serve

# Stop a model (free memory)
ollama stop llama3
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Ollama not running | Run `ollama serve` |
| Model not found | Run `ollama pull llama3` |
| Slow generation | Use smaller model (`llama3` over `llama3.1:70b`) |
| Out of memory | Use quantized model (`llama3:8b-q4_0`) |
| Empty/invalid JSON | Ensure `"format": "json"` in request |
| Timeout | Increase `timeout` in `requests.post()` (default 300s) |
| Hindi output poor | Try `llama3.1:8b` — better multilingual support |

---

## Notes

- **RAM requirements:** `llama3` (8B) needs ~8GB RAM. Quantized versions need less.
- **GPU acceleration:** Ollama auto-detects NVIDIA GPUs. Speeds up generation 5-10x.
- **`format: "json"`** forces the model to output valid JSON (Ollama built-in feature).
- **Model fallback** ensures resilience — if one model fails, the next one is tried.
- **Same prompt** is used for both Gemini and Ollama modes, ensuring consistent output format.
