## Instagram Video Downloader (CLI + API)

This small tool lets you **download Instagram videos** and optionally **upload them to your own API** from the command line.

The main script is `instagram_video_downloader.py`.

---

### 1. Requirements

- **Python** 3.8+
- Recommended to use a **virtual environment**

Install dependencies (CLI only):

```bash
pip install instaloader requests
```

Or, for the CLI **and** the HTTP API:

```bash
pip install instaloader requests fastapi uvicorn
```

---

### 2. Basic Usage

Download a public Instagram video and print its metadata as JSON:

```bash
python instagram_video_downloader.py "https://www.instagram.com/p/SHORTCODE/"
```

Notes:

- Replace `SHORTCODE` with the post/reel/tv shortcode from the URL.
- Supports URLs like:
  - `https://www.instagram.com/p/SHORTCODE/`
  - `https://www.instagram.com/reel/SHORTCODE/`
  - `https://www.instagram.com/tv/SHORTCODE/`

---

### 3. Using Instagram Login (for private posts you can access)

If you need to download videos from private accounts you follow, or want to reduce rate-limit issues, you can provide login credentials:

```bash
python instagram_video_downloader.py \
  "https://www.instagram.com/p/SHORTCODE/" \
  --ig-username "your_ig_username" \
  --ig-password "your_ig_password"
```

Or provide an existing Instaloader session file:

```bash
python instagram_video_downloader.py \
  "https://www.instagram.com/p/SHORTCODE/" \
  --ig-username "your_ig_username" \
  --ig-sessionfile "path/to/sessionfile"
```

> **Security tip**: Prefer environment variables, `.env`, or a session file instead of hard-coding credentials in scripts.

---

### 4. Uploading to a Custom API

You can upload the downloaded video and its metadata to your own server via a configurable API endpoint.

Example with Bearer token authentication:

```bash
python instagram_video_downloader.py \
  "https://www.instagram.com/p/SHORTCODE/" \
  --api-url "https://api.example.com/upload" \
  --api-token "YOUR_API_TOKEN"
```

The request is sent as `multipart/form-data` with:

- **file**: the `.mp4` video file
- **metadata**: JSON string containing metadata, for example:

```json
{
  "shortcode": "SHORTCODE",
  "source_url": "https://www.instagram.com/p/SHORTCODE/",
  "is_video": true,
  "video_url": "https://...",
  "title": "Optional title",
  "caption": "Post caption text",
  "upload_date": "2024-01-01T12:00:00",
  "author_username": "username",
  "view_count": 1234,
  "like_count": 567,
  "comment_count": 10,
  "thumbnail_url": "https://..."
}
```

Additional options:

- `--no-verify-ssl` – disable SSL verification (not recommended in production).
- `--api-timeout` – request timeout in seconds (default: `60`).

---

### 5. Output Directory & Cleanup

By default, the script downloads into a **temporary directory** and deletes it after completion.

If you want to keep the downloaded file:

```bash
python instagram_video_downloader.py "https://www.instagram.com/p/SHORTCODE/" --keep-file
```

Or specify a custom output directory (which will not be deleted automatically):

```bash
python instagram_video_downloader.py \
  "https://www.instagram.com/p/SHORTCODE/" \
  --output-dir "./downloads"
```

---

### 6. HTTP API (for Flutter / other clients)

There is a small FastAPI app in `video_downloader_api.py` that exposes HTTP endpoints your Flutter app can call.

- **Instagram endpoint**: `POST /instagram/download`
- **Snapchat endpoint**: `POST /snapchat/download`

Shared request body shape:

```json
{
  "url": "https://<platform-url-here>"
}
```

For Instagram, `url` is a normal Instagram post/reel URL.  
For Snapchat, `url` is a normal public Spotlight/share URL; the server scrapes the page to find the real video URL and metadata.

---

#### 6.1 Instagram response example

  ```json
  {
    "file_path": "D:/projects/ai-practice/video_downloder_python/downloads/SHORTCODE/2024-01-01_12-00_UTC_XXXX.mp4",
    "metadata": {
      "shortcode": "SHORTCODE",
      "source_url": "https://www.instagram.com/p/SHORTCODE/",
      "is_video": true,
      "video_url": "https://...",
      "title": "Optional title",
      "caption": "Post caption text",
      "upload_date": "2024-01-01T12:00:00",
      "author_username": "username",
      "view_count": 1234,
      "like_count": 567,
      "comment_count": 10,
      "thumbnail_url": "https://..."
    }
  }
  ```

#### 6.2 Snapchat response example

```json
{
  "file_path": "D:/projects/ai-practice/video_downloder_python/downloads_snapchat/Prince_Soni1000_Posted_Mar_3_2026_Spotlight_20260303T200922Z.mp4",
  "metadata": {
    "source_url": "https://www.snapchat.com/@user/spotlight/....",
    "downloaded_at_utc": "2026-03-03T20:09:22.123456",
    "file_name": "Prince_Soni1000_Posted_Mar_3_2026_Spotlight_20260303T200922Z.mp4",
    "file_size_bytes": 1234567,
    "content_type": "video/mp4",
    "page_title": "◉⁠‿⁠◉Prince_Soni1000 (@prince_soni1000) | Posted Mar 3, 2026 | Spotlight"
  }
}
```

The Snapchat downloader:

- Strips query parameters (like `share_id`, `locale`) from the URL.
- Fetches the HTML page and finds the direct video URL from `<source type="video/mp4">` / `<video src="...">`.
- Uses the `og:title` meta tag to build a safe, human-readable file name.

---

#### 6.3 Run the API server

From the `video_downloder_python` directory:

```bash
python -m uvicorn video_downloader_api:app --host 0.0.0.0 --port 8000
```

Then open in a browser:

- API docs (Swagger UI): `http://localhost:8000/docs`
- Health check: try a test `POST /instagram/download` and `POST /snapchat/download` from the docs UI.

Downloaded files are stored under `downloads_instagram` and `downloads_snapchat` next to the scripts and **are not deleted automatically**, so your Flutter app can access the file path.

#### 6.4 Call from Flutter (example)

Using the `http` package:

```dart
final response = await http.post(
  Uri.parse('http://<YOUR_PC_IP>:8000/instagram/download'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'url': instagramUrl}),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  final localPath = data['file_path'];  // path on the server machine
  final metadata = data['metadata'];
} else {
  // handle error
}
```

Make sure your phone/emulator can reach your PC IP over the network (same Wi‑Fi, firewall open for port 8000, etc.).

For Snapchat, call `http://localhost:8000/snapchat/download` with the same JSON shape but a public Snapchat URL, then use:

- `data['file_path']` for the local path on the server, and
- `data['metadata']['page_title']` / `data['metadata']['file_name']` for display in your app.

---

### 7. Verbose Logging

Enable more detailed logs:

```bash
python instagram_video_downloader.py "https://www.instagram.com/p/SHORTCODE/" --verbose
```

---

### 8. Command-Line Arguments Summary

```text
positional arguments:
  url                   Instagram video URL (post / reel / tv)

optional arguments:
  --ig-username USERNAME     Instagram username (optional)
  --ig-password PASSWORD     Instagram password (optional)
  --ig-sessionfile PATH      Path to Instaloader session file (optional)

  --api-url URL              Custom API URL for upload (optional)
  --api-token TOKEN          Bearer token for the API (optional)
  --no-verify-ssl            Disable SSL verification for API requests
  --api-timeout SECONDS      API request timeout (default: 60)

  --output-dir PATH          Directory to store downloaded files
  --keep-file                Do not delete downloaded files after completion
  --verbose                  Enable verbose logging
```

---

### 9. Error Handling

The script includes error handling for:

- Invalid or unsupported Instagram URLs
- Download failures (e.g., network issues, non-video posts)
- Authentication errors (Instagram or API)
- API failures (non-2xx responses, timeouts, connection issues)

Exit codes:

- `0` – success
- `1` – validation, download, or upload error
- `130` – interrupted by user (`Ctrl+C`)

