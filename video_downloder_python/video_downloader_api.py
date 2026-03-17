"""
Unified Video Download API

Single FastAPI application that exposes:

- POST /instagram/download  (Instagram video)
- POST /snapchat/download   (Snapchat video, direct URL)

So you only need to run one server and one `/docs`:

    python -m uvicorn video_downloader_api:app --host 0.0.0.0 --port 8000
"""

from __future__ import annotations

import json
import logging
import os
import subprocess
from typing import Any, Dict, Optional

import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, HttpUrl

from instagram_video_downloader import (
    InstagramDownloadError,
    cleanup_directory,
    download_instagram_video,
)
from snapchat_video_downloader import (
    SnapchatDownloadError,
    download_snapchat_video,
)


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("video_downloader_api")


BASE_DIR = os.path.dirname(__file__)
SNAPCHAT_DOWNLOAD_ROOT = os.path.join(BASE_DIR, "downloads_snapchat")

# WidCash API configuration
WIDCASH_API_BASE = os.environ.get("WIDCASH_API_BASE", "https://widcash.preptm.com")
WIDCASH_UPLOAD_URL = f"{WIDCASH_API_BASE}/api/Reel/upload"


class InstagramDownloadRequest(BaseModel):
    url: HttpUrl


class InstagramDownloadResponse(BaseModel):
    video_url: str
    metadata: Dict[str, Any]


class SnapchatDownloadRequest(BaseModel):
    url: HttpUrl


class SnapchatDownloadResponse(BaseModel):
    video_url: str
    metadata: Dict[str, Any]


app = FastAPI(
    title="Video Download API",
    description=(
        "Download Instagram and Snapchat videos locally and return the local file path + metadata.\n\n"
        "- POST /instagram/download\n"
        "- POST /snapchat/download"
    ),
    version="1.0.0",
)


def upload_video_to_widcash(
    file_path: str,
    additional_data: str = "",
    keyword: str = "",
    timeout: int =2000,
) -> str:
    """
    Upload a video file to the WidCash Reel API and return the hosted URL.

    Sends multipart/form-data with:
      - File: the video file
      - AdditionalData: metadata string
      - Keyword: keyword tag

    Returns:
        The hosted video URL from the API response.

    Raises:
        HTTPException: If the upload fails.
    """
    logger.info("Uploading video to WidCash API via curl: %s", WIDCASH_UPLOAD_URL)

    cmd = [
        "curl", "-s", "-w", "\n%{http_code}",
        "-X", "POST", WIDCASH_UPLOAD_URL,
        "-F", f"AdditionalData={additional_data}",
        "-F", f"Keyword={keyword}",
        "-F", f"File=@{file_path};type=video/mp4",
    ]

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout,
        )
    except subprocess.TimeoutExpired as exc:
        raise HTTPException(status_code=504, detail="WidCash upload timed out") from exc

    output = result.stdout.strip()
    lines = output.rsplit("\n", 1)

    if len(lines) < 2:
        logger.error("Unexpected curl output: %s", output)
        raise HTTPException(status_code=502, detail="WidCash upload failed: unexpected response")

    response_body, http_code = lines[0], lines[1]
    logger.info("WidCash response (HTTP %s): %s", http_code, response_body[:500])

    if not http_code.startswith("2"):
        raise HTTPException(
            status_code=502,
            detail=f"WidCash upload failed with status {http_code}: {response_body[:300]}",
        )

    body = json.loads(response_body)
    if not body.get("success"):
        logger.error("WidCash upload returned error: %s", body.get("message"))
        raise HTTPException(
            status_code=502,
            detail=f"WidCash upload error: {body.get('message')}",
        )

    # Response: {"success": true, "message": "...", "data": "https://...url..."}
    video_url = body.get("data")
    if not video_url:
        raise HTTPException(status_code=502, detail="WidCash upload returned no video URL")

    logger.info("WidCash upload successful. Video URL: %s", video_url)
    return video_url


@app.post("/instagram/download", response_model=InstagramDownloadResponse, tags=["instagram"])
async def instagram_download_endpoint(
    payload: InstagramDownloadRequest,
) -> InstagramDownloadResponse:
    """
    Download an Instagram video, upload it to WidCash API, and return the hosted URL + metadata.
    Video is downloaded to a temp directory and cleaned up after upload.
    """
    logger.info("IG Step 1: Received /instagram/download request with URL=%s", payload.url)

    working_dir: Optional[str] = None

    try:
        # Step 2: Download to temp directory (output_dir=None uses tempdir)
        logger.info("IG Step 2: Downloading video to temp directory")
        video_path, metadata, working_dir = download_instagram_video(
            url=str(payload.url),
        )

        logger.info("IG Step 3: Download finished. Temp path: %s", video_path)

        # Step 4: Upload to WidCash API — send only key metadata fields
        meta_for_upload = {
            "title": metadata.get("title") or "",
            "description": metadata.get("caption") or "",
            "likesCount": metadata.get("like_count") or 0,
            "commentCount": metadata.get("comment_count") or 0,
            "shareCount": 0,
            "username": metadata.get("author_username") or "",
        }
        additional_data = json.dumps(meta_for_upload, ensure_ascii=False, default=str)
        keyword = ""

        video_url = upload_video_to_widcash(
            file_path=video_path,
            additional_data=additional_data,
            keyword=keyword,
        )

        logger.info("IG Step 5: Upload complete. Hosted URL: %s", video_url)

        response = InstagramDownloadResponse(
            video_url=video_url,
            metadata=metadata,
        )
        logger.info("IG Step 6: Returning response to client.")
        return response

    except InstagramDownloadError as exc:
        logger.error("Instagram download error: %s", exc)
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as exc:  # noqa: BLE001
        logger.exception(
            "Unexpected server error while handling /instagram/download: %s", exc
        )
        raise HTTPException(status_code=500, detail="Internal server error") from exc
    finally:
        # Always clean up temp directory
        if working_dir:
            cleanup_directory(working_dir)


@app.post("/snapchat/download", response_model=SnapchatDownloadResponse, tags=["snapchat"])
async def snapchat_download_endpoint(
    payload: SnapchatDownloadRequest,
) -> SnapchatDownloadResponse:
    """
    Download a Snapchat video, upload it to WidCash API, and return the hosted URL + metadata.
    Video is downloaded to a temp directory and cleaned up after upload.
    """
    logger.info("SC Step 1: Received /snapchat/download request with URL=%s", payload.url)

    working_dir: Optional[str] = None

    try:
        # Step 2: Download to temp directory
        logger.info("SC Step 2: Downloading video to temp directory")
        video_path, metadata, working_dir = download_snapchat_video(
            url=str(payload.url),
        )

        logger.info("SC Step 3: Download finished. Temp path: %s", video_path)

        # Step 4: Upload to WidCash API
        meta_for_upload = {
            "title": metadata.get("page_title") or "",
            "description": "",
            "likesCount": 0,
            "commentCount": 0,
            "shareCount": 0,
            "username": "",
        }
        additional_data = json.dumps(meta_for_upload, ensure_ascii=False, default=str)

        video_url = upload_video_to_widcash(
            file_path=video_path,
            additional_data=additional_data,
            keyword=payload.keyword or "funny, entertainment, snapchat",
        )

        logger.info("SC Step 5: Upload complete. Hosted URL: %s", video_url)

        metadata["video_url"] = video_url

        response = SnapchatDownloadResponse(
            video_url=video_url,
            metadata=metadata,
        )
        logger.info("SC Step 6: Returning response to client.")
        return response

    except SnapchatDownloadError as exc:
        logger.error("Snapchat download error: %s", exc)
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except HTTPException:
        raise
    except Exception as exc:  # noqa: BLE001
        logger.exception(
            "Unexpected server error while handling /snapchat/download: %s", exc
        )
        raise HTTPException(status_code=500, detail="Internal server error") from exc
    finally:
        # Always clean up temp directory
        if working_dir:
            cleanup_directory(working_dir)

