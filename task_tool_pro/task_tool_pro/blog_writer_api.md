# Blog Writer — Python API Setup

## Overview

FastAPI server that receives a blog URL, scrapes the content, rewrites it using Google Gemini, and returns the result.

## Requirements

```bash
pip install fastapi uvicorn requests beautifulsoup4 google-generativeai
```

## Project Structure

```
blog_api/
├── main.py
```

## main.py

```python
from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import google.generativeai as genai

app = FastAPI()

# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class BlogRequest(BaseModel):
    url: str

class BlogResponse(BaseModel):
    content: str

# ---------------------------------------------------------------------------
# Helper — scrape blog text from URL
# ---------------------------------------------------------------------------

def scrape_blog_text(url: str) -> str:
    try:
        resp = requests.get(url, timeout=15, headers={
            "User-Agent": "Mozilla/5.0"
        })
        resp.raise_for_status()
    except requests.RequestException as e:
        raise HTTPException(status_code=400, detail=f"Failed to fetch URL: {e}")

    soup = BeautifulSoup(resp.text, "html.parser")

    # Remove script, style, nav, footer tags
    for tag in soup(["script", "style", "nav", "footer", "header", "aside"]):
        tag.decompose()

    # Try common article containers first
    article = (
        soup.find("article")
        or soup.find("div", class_="post-content")
        or soup.find("div", class_="entry-content")
        or soup.find("div", class_="article-body")
        or soup.find("main")
    )

    text = article.get_text(separator="\n", strip=True) if article else soup.body.get_text(separator="\n", strip=True)

    if len(text) < 100:
        raise HTTPException(status_code=400, detail="Could not extract enough content from the URL.")

    return text

# ---------------------------------------------------------------------------
# Helper — rewrite with Gemini
# ---------------------------------------------------------------------------

def rewrite_with_gemini(original_text: str, api_token: str) -> str:
    genai.configure(api_key=api_token)
    model = genai.GenerativeModel("gemini-2.0-flash")

    prompt = f"""You are a professional blog writer.
Rewrite the following blog content into a well-structured, engaging blog post.
Keep the same topic and key information but make it original, readable, and SEO-friendly.
Use proper headings, paragraphs, and a conversational tone.

Original content:
---
{original_text[:15000]}
---

Write the rewritten blog post:"""

    response = model.generate_content(prompt)
    return response.text

# ---------------------------------------------------------------------------
# API endpoint
# ---------------------------------------------------------------------------

@app.post("/api/blog/generate", response_model=BlogResponse)
def generate_blog(body: BlogRequest, authorization: str = Header(...)):
    # Extract token from "Bearer <token>"
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header.")

    api_token = authorization.removeprefix("Bearer ").strip()
    if not api_token:
        raise HTTPException(status_code=401, detail="API token is empty.")

    # Step 1 — scrape
    original_text = scrape_blog_text(body.url)

    # Step 2 — rewrite with Gemini
    blog_content = rewrite_with_gemini(original_text, api_token)

    return BlogResponse(content=blog_content)
```

## Run the server

```bash
cd blog_api
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Server starts at `http://localhost:8000`.

## API Contract

### `POST /api/blog/generate`

**Headers:**
| Header          | Value                    |
|-----------------|--------------------------|
| Authorization   | `Bearer <GEMINI_API_KEY>` |
| Content-Type    | `application/json`        |

**Request body:**
```json
{
  "url": "https://example.com/some-blog-post"
}
```

**Success response (200):**
```json
{
  "content": "# Rewritten Blog Title\n\nRewritten blog content..."
}
```

**Error responses:**
| Status | When                          |
|--------|-------------------------------|
| 400    | URL unreachable or no content |
| 401    | Missing or invalid token      |
| 500    | Gemini API failure            |

## Token Setup

The **token** you set in the Flutter app is your **Google Gemini API key**.

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Create an API key
3. Paste it in the Blog Writer settings (gear icon) in the app

## Test with curl

```bash
curl -X POST http://localhost:8000/api/blog/generate \
  -H "Authorization: Bearer YOUR_GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/blog-post"}'
```
