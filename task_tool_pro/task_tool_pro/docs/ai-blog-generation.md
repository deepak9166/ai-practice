# Flutter Desktop App Specification (flutter_app.spec.md)

## 1. Overview

Flutter app provides UI for:

* Input blog URL
* Select category & tags
* Select AI mode (Local / Gemini)
* Preview generated content
* Publish blog via API

---

## 2. Main Features

* URL input field
* Dropdown:

  * Category
  * Blog Type
* Tags multi-select
* AI Mode toggle:

  * Local (Ollama)
  * Gemini
* Preview screen
* Publish button

---

## 3. API Integrations

### 1. Python AI Service

POST http://localhost:8000/process-blog

### 2. Blog Publish API

POST https://api.preptm.com/api/translation/article/AddUpdate

---

## 4. Headers

```
Content-Type: application/json
Authorization: Bearer <STATIC_TOKEN>
```

---

## 5. Step-by-Step Flow

### Step 1: User Input

* Enter blog URL
* Select:

  * Category
  * Tags
  * Mode (local/gemini)

---

### Step 2: Call Python API

```dart
final response = await http.post(
  Uri.parse("http://localhost:8000/process-blog"),
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer YOUR_TOKEN"
  },
  body: jsonEncode({
    "url": url,
    "mode": mode,
    "category_id": categoryId,
    "tags": selectedTags
  }),
);
```

---

### Step 3: Handle Response

#### Success Case

```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);

  if (data["success"] == true) {
    final blogData = data["data"];

    // Navigate to preview screen
  }
}
```

---

### Step 4: Preview Screen

Show:

* Title
* Description
* Summary
* Keywords

Allow:

* Manual edit before publish

---

### Step 5: Publish API Call

```dart
await http.post(
  Uri.parse("https://api.preptm.com/api/translation/article/AddUpdate"),
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer YOUR_TOKEN"
  },
  body: jsonEncode({
    "id": 0,
    ...blogData
  }),
);
```

---

## 6. Success Response Handling

```dart
{
  "isSuccess": true,
  "message": "Record Saved Successfully",
  "statusCode": 200,
  "data": 107
}
```

### Action

* Show success snackbar
* Clear form
* Optionally redirect

---

## 7. Error Handling

### API Error

```dart
if (response.statusCode != 200) {
  showError("Server error");
}
```

### Logical Error

```dart
if (data["isSuccess"] == false) {
  showError(data["message"]);
}
```

---

## 8. UI States

| State   | Description    |
| ------- | -------------- |
| Idle    | Default screen |
| Loading | Show loader    |
| Success | Show preview   |
| Error   | Show message   |

---

## 9. Architecture Suggestion

* State Management: Riverpod / Bloc
* Networking: Dio (recommended)
* Models:

  * BlogRequestModel
  * BlogResponseModel

---

## 10. Model Example

```dart
class BlogModel {
  String title;
  String description;
  String summary;
  String keywords;
}
```

---

## 11. Validation

* URL must not be empty
* Category required
* Tags optional

---

## 12. Future Enhancements

* Save drafts locally
* History of generated blogs
* Bulk URL processing
* Retry mechanism

---
