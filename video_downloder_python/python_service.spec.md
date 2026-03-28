# Python AI Service Specification (python_service.spec.md)

## 1. Overview

This service is responsible for:

* Fetching blog data from a URL
* Cleaning and extracting meaningful content
* Processing content using AI (Local via Ollama or Cloud via Gemini)
* Returning structured JSON for publishing

---

## 2. Tech Stack

* FastAPI (API server)
* BeautifulSoup (HTML parsing)
* Requests (HTTP calls)
* Ollama (local AI)
* Gemini (optional cloud AI)

---

## 3. Base URL

http://localhost:8000

---

## 4. API Endpoint

### POST /process-blog

---

## 5. Request Structure

### Headers

```
Content-Type: application/json
Authorization: Bearer <STATIC_TOKEN>
```

### Body

```json
{
  "url": "https://example.com/blog",
  "mode": "local", 
  "category_id": 53,
  "tags": [13,6,21]
}
```

### Field Details

| Field       | Type       | Description         |
| ----------- | ---------- | ------------------- |
| url         | string     | Blog URL to scrape  |
| mode        | string     | "local" or "gemini" |
| category_id | int        | Selected category   |
| tags        | array<int> | Tag IDs             |

---

## 6. Processing Flow

1. Validate request
2. Fetch blog HTML
3. Extract:

   * Title
   * Paragraph content
4. Clean content:

   * Remove scripts, styles
   * Remove ads / navbars
5. Send to AI:

   * If mode = local → Ollama
   * If mode = gemini → Gemini API
6. AI returns structured JSON
7. Transform into final API format
8. Return response to Flutter

---

## 7. AI Prompt Structure

```
Rewrite the blog content and return ONLY JSON:

{
  "title": "",
  "titleHindi": "",
  "description": "",
  "descriptionHindi": "",
  "summary": "",
  "summaryHindi": "",
  "keywords": "",
  "keywordHindi": "",
  "content": ""
}
```

---

## 8. Ollama Integration

### Endpoint

http://localhost:11434/api/generate

### Request

```json
{
  "model": "llama3",
  "prompt": "<PROMPT>"
}
```

---

## 9. Final Response Format (to Flutter)

```json
{
  "success": true,
  "data": {
    "title": "Generated Title",
    "titleHindi": "Generated Hindi Title",
    "articleType": 53,
    "slugUrl": "generated-slug",
    "keywords": "keyword1, keyword2",
    "keywordHindi": "keyword hindi",
    "description": "<p>HTML content</p>",
    "descriptionHindi": "<p>Hindi content</p>",
    "summary": "Short summary",
    "summaryHindi": "Hindi summary",
    "thumbnail": "",
    "thumbnailCredit": null,
    "articleFaqsDTOs": [],
    "articleTagsDTOs": [13,6,21],
    "descriptionJson": "{}",
    "descriptionJsonHindi": "{}"
  }
}
```

---

## 10. Error Response

```json
{
  "success": false,
  "message": "Error message"
}
```

---

## 11. Error Handling

| Case            | Handling            |
| --------------- | ------------------- |
| Invalid URL     | Return 400          |
| Scraping failed | Return error        |
| AI failed       | Retry 1 time        |
| JSON invalid    | Fix or return error |

---

## 12. Security

* Validate Authorization header
* Use static token for now
* Future: JWT validation

---

## 13. Future Improvements

* Add caching
* Add queue system
* Add multiple model selection
* Add content plagiarism check

---
