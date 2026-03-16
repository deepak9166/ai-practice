# How to Run — Video Downloader Python

## Prerequisites

- **Python** 3.8+ (tested with 3.14.3)
- **pip** (comes with Python)

---

## 1. Clone & Navigate

```bash
cd d:/projects/ai-practice/video_downloder_python
```

---

## 2. Create Virtual Environment (recommended)

```bash
python -m venv venv
```

Activate it:

```bash
# Windows (Git Bash / MSYS2)
source venv/Scripts/activate

# Windows (CMD)
venv\Scripts\activate

# Windows (PowerShell)
venv\Scripts\Activate.ps1

# macOS / Linux
source venv/bin/activate
```

---

## 3. Install Dependencies

```bash
pip install instaloader requests fastapi uvicorn beautifulsoup4
```

### Packages Summary

| Package          | Purpose                        |
|------------------|--------------------------------|
| `instaloader`    | Instagram video downloading    |
| `requests`       | HTTP requests                  |
| `fastapi`        | API framework                  |
| `uvicorn`        | ASGI server to run FastAPI     |
| `beautifulsoup4` | Snapchat HTML page parsing     |

---

## 4. Run the API Server

```bash
python -m uvicorn video_downloader_api:app --host 0.0.0.0 --port 8000
```

Server will start at:

| URL                           | Description       |
|-------------------------------|-------------------|
| `http://localhost:8000`       | API base          |
| `http://localhost:8000/docs`  | Swagger UI (test endpoints here) |

---

## 5. API Endpoints

### Download Instagram Video

```
POST http://localhost:8000/instagram/download
Content-Type: application/json

{
  "url": "https://www.instagram.com/reel/SHORTCODE/"
}
```

### Download Snapchat Video

```
POST http://localhost:8000/snapchat/download
Content-Type: application/json

{
  "url": "https://www.snapchat.com/@user/spotlight/..."
}
```

### Response Format (both)

```json
{
  "file_path": "D:/projects/.../video.mp4",
  "metadata": {
    "shortcode": "...",
    "source_url": "...",
    "is_video": true,
    ...
  }
}
```

---

## 6. CLI Usage (Instagram only)

Download a video directly from the command line:

```bash
python instagram_video_downloader.py "https://www.instagram.com/reel/SHORTCODE/"
```

Keep the downloaded file:

```bash
python instagram_video_downloader.py "https://www.instagram.com/reel/SHORTCODE/" --keep-file
```

Custom output directory:

```bash
python instagram_video_downloader.py "https://www.instagram.com/reel/SHORTCODE/" --output-dir "./downloads"
```

---

## 7. Call from Flutter

Make sure your phone/emulator is on the same network as your PC.

```dart
final response = await http.post(
  Uri.parse('http://<YOUR_PC_IP>:8000/instagram/download'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'url': instagramUrl}),
);

final data = jsonDecode(response.body);
print(data['file_path']);
print(data['metadata']);
```

---

## 8. Project Structure

```
video_downloder_python/
├── video_downloader_api.py           # FastAPI server (main entry point)
├── instagram_video_downloader.py     # Instagram download logic
├── snapchat_video_downloader.py      # Snapchat download logic
├── README.md                         # Detailed documentation
├── HOW_TO_RUN.md                     # This file
├── docs/
│   └── upload-video.md               # WidCash API reference
├── downloads_instagram/              # Downloaded Instagram videos
└── downloads_snapchat/               # Downloaded Snapchat videos
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `ModuleNotFoundError: No module named 'instaloader'` | Run `pip install instaloader` |
| `ModuleNotFoundError: No module named 'fastapi'` | Run `pip install fastapi uvicorn` |
| `Address already in use` | Another process on port 8000. Kill it or use `--port 8001` |
| Instagram rate limit / login required | Use `--ig-username` and `--ig-password` flags (CLI only) |
| Flutter can't connect | Check firewall allows port 8000, use PC's local IP (not `localhost`) |
