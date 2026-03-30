# Flutter Integration Guide — `/process-blog` API

## Base URL

```
http://<your-server-ip>:8000
```

---

## Endpoint

### POST `/process-blog`

| Field           | Type       | Required | Description                          |
|-----------------|------------|----------|--------------------------------------|
| `url`           | `String`   | Yes      | Blog URL to scrape and rewrite       |
| `mode`          | `String`   | Yes      | `"local"` (Ollama) or `"gemini"`     |
| `category_id`   | `int`      | No       | Article category ID (default: 0)     |
| `tags`          | `List<int>`| No       | Tag IDs (default: [])                |
| `gemini_api_key`| `String?`  | No       | Required only when mode = `"gemini"` |

---

## Request Example

```json
{
  "url": "https://example.com/blog-post",
  "mode": "gemini",
  "category_id": 53,
  "tags": [13, 6, 21],
  "gemini_api_key": "YOUR_GEMINI_API_KEY"
}
```

---

## Success Response (200)

```json
{
  "success": true,
  "data": {
    "title": "Generated English Title",
    "titleHindi": "Hindi Title",
    "articleType": 53,
    "slugUrl": "generated-english-title",
    "keywords": "keyword1, keyword2, keyword3",
    "keywordHindi": "hindi keyword1, hindi keyword2",
    "description": "<p>Full rewritten HTML blog content</p>",
    "descriptionHindi": "<p>Hindi HTML content</p>",
    "summary": "2-3 sentence English summary",
    "summaryHindi": "Hindi summary",
    "thumbnail": "",
    "thumbnailCredit": null,
    "articleFaqsDTOs": [
      {
        "id": 0,
        "que": "What is FastAPI?",
        "ans": "FastAPI is a modern Python web framework...",
        "queHindi": "FastAPI क्या है?",
        "ansHindi": "FastAPI एक आधुनिक Python वेब फ्रेमवर्क है...",
        "isUpdate": false
      }
    ],
    "articleTagsDTOs": [13, 6, 21],
    "descriptionJson": "{}",
    "descriptionJsonHindi": "{}"
  }
}
```

---

## Error Response

```json
{
  "success": false,
  "message": "Error description here"
}
```

---

## Flutter Dart Code

### 1. Model Class

```dart
class ProcessBlogRequest {
  final String url;
  final String mode; // "local" or "gemini"
  final int categoryId;
  final List<int> tags;
  final String? geminiApiKey;

  ProcessBlogRequest({
    required this.url,
    this.mode = 'local',
    this.categoryId = 0,
    this.tags = const [],
    this.geminiApiKey,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'mode': mode,
        'category_id': categoryId,
        'tags': tags,
        if (geminiApiKey != null) 'gemini_api_key': geminiApiKey,
      };
}
```

### 2. Response Model

```dart
class BlogArticleData {
  final String title;
  final String titleHindi;
  final int articleType;
  final String slugUrl;
  final String keywords;
  final String keywordHindi;
  final String description;
  final String descriptionHindi;
  final String summary;
  final String summaryHindi;
  final String thumbnail;
  final String? thumbnailCredit;
  final List<dynamic> articleFaqsDTOs;
  final List<int> articleTagsDTOs;
  final String descriptionJson;
  final String descriptionJsonHindi;

  BlogArticleData({
    required this.title,
    required this.titleHindi,
    required this.articleType,
    required this.slugUrl,
    required this.keywords,
    required this.keywordHindi,
    required this.description,
    required this.descriptionHindi,
    required this.summary,
    required this.summaryHindi,
    this.thumbnail = '',
    this.thumbnailCredit,
    this.articleFaqsDTOs = const [],
    this.articleTagsDTOs = const [],
    this.descriptionJson = '{}',
    this.descriptionJsonHindi = '{}',
  });

  factory BlogArticleData.fromJson(Map<String, dynamic> json) {
    return BlogArticleData(
      title: json['title'] ?? '',
      titleHindi: json['titleHindi'] ?? '',
      articleType: json['articleType'] ?? 0,
      slugUrl: json['slugUrl'] ?? '',
      keywords: json['keywords'] ?? '',
      keywordHindi: json['keywordHindi'] ?? '',
      description: json['description'] ?? '',
      descriptionHindi: json['descriptionHindi'] ?? '',
      summary: json['summary'] ?? '',
      summaryHindi: json['summaryHindi'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      thumbnailCredit: json['thumbnailCredit'],
      articleFaqsDTOs: json['articleFaqsDTOs'] ?? [],
      articleTagsDTOs: List<int>.from(json['articleTagsDTOs'] ?? []),
      descriptionJson: json['descriptionJson'] ?? '{}',
      descriptionJsonHindi: json['descriptionJsonHindi'] ?? '{}',
    );
  }
}

class ProcessBlogResponse {
  final bool success;
  final String? message;
  final BlogArticleData? data;

  ProcessBlogResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ProcessBlogResponse.fromJson(Map<String, dynamic> json) {
    return ProcessBlogResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? BlogArticleData.fromJson(json['data'])
          : null,
    );
  }
}
```

### 3. API Service

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogApiService {
  static const String _baseUrl = 'http://YOUR_SERVER_IP:8000';

  Future<ProcessBlogResponse> processBlog(ProcessBlogRequest request) async {
    final uri = Uri.parse('$_baseUrl/process-blog');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ProcessBlogResponse.fromJson(json);
  }
}
```

### 4. Usage in Widget / ViewModel

```dart
final blogApi = BlogApiService();

Future<void> onProcessBlog() async {
  final request = ProcessBlogRequest(
    url: 'https://example.com/blog-post',
    mode: 'gemini',
    categoryId: 53,
    tags: [13, 6, 21],
    geminiApiKey: 'YOUR_GEMINI_API_KEY',
  );

  final response = await blogApi.processBlog(request);

  if (response.success && response.data != null) {
    final article = response.data!;
    print('Title: ${article.title}');
    print('Slug: ${article.slugUrl}');
    print('Summary: ${article.summary}');
    // Use article data to populate form fields or publish directly
  } else {
    print('Error: ${response.message}');
  }
}
```

---

## Notes

- **Mode `"local"`** requires Ollama running at `http://localhost:11434` with model `llama3`
- **Mode `"gemini"`** requires a valid Gemini API key passed in the request
- AI processing can take 30-120 seconds depending on content length and model
- The response `description` and `descriptionHindi` contain HTML (`<p>` tags) — render with a WebView or HTML widget
- The `slugUrl` is auto-generated from the AI-rewritten title
- Set a longer HTTP timeout on the Flutter side (at least 120 seconds)

---

## cURL Test

```bash
curl -X POST http://localhost:8000/process-blog \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/blog",
    "mode": "gemini",
    "category_id": 53,
    "tags": [13, 6, 21],
    "gemini_api_key": "YOUR_KEY"
  }'
```

Or test via Swagger UI: `http://localhost:8000/docs`
