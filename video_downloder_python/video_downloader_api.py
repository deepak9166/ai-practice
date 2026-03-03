"""
Unified Video Download API

Single FastAPI application that exposes:

- POST /instagram/download  (Instagram video)
- POST /snapchat/download   (Snapchat video, direct URL)

So you only need to run one server and one `/docs`:

    python -m uvicorn video_downloader_api:app --host 0.0.0.0 --port 8000
"""

from __future__ import annotations

import logging
import os
from typing import Any, Dict

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, HttpUrl

from instagram_video_downloader import (
    InstagramDownloadError,
    download_instagram_video,
    parse_instagram_url,
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
INSTAGRAM_DOWNLOAD_ROOT = os.path.join(BASE_DIR, "downloads_instagram")
SNAPCHAT_DOWNLOAD_ROOT = os.path.join(BASE_DIR, "downloads_snapchat")


class InstagramDownloadRequest(BaseModel):
    url: HttpUrl


class InstagramDownloadResponse(BaseModel):
    file_path: str
    metadata: Dict[str, Any]


class SnapchatDownloadRequest(BaseModel):
    url: HttpUrl


class SnapchatDownloadResponse(BaseModel):
    file_path: str
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


@app.post("/instagram/download", response_model=InstagramDownloadResponse, tags=["instagram"])
async def instagram_download_endpoint(
    payload: InstagramDownloadRequest,
) -> InstagramDownloadResponse:
    """
    Download an Instagram video and return local path + metadata.
    """
    logger.info("IG Step 1: Received /instagram/download request with URL=%s", payload.url)

    try:
        logger.info(
            "IG Step 2: Starting download into root folder: %s",
            INSTAGRAM_DOWNLOAD_ROOT,
        )
        video_path, metadata, _working_dir = download_instagram_video(
            url=str(payload.url),
            output_dir=INSTAGRAM_DOWNLOAD_ROOT,
        )

        abs_path = os.path.abspath(video_path)
        logger.info("IG Step 3: Download finished. Local video path: %s", abs_path)
        logger.info("IG Step 4: Metadata keys: %s", list(metadata.keys()))

        response = InstagramDownloadResponse(
            file_path=abs_path,
            metadata=metadata,
        )
        logger.info("IG Step 5: Returning successful Instagram response to client.")
        return response

    except InstagramDownloadError as exc:
        logger.error("Instagram download error: %s", exc)

        # Fallback: if an existing video file for this shortcode is already on disk,
        # return that instead of failing.
        try:
            shortcode = parse_instagram_url(str(payload.url))
            fallback_dir = os.path.join(INSTAGRAM_DOWNLOAD_ROOT, shortcode)
            logger.info(
                "IG Fallback check: looking for existing video under %s", fallback_dir
            )

            existing_video_path = None
            if os.path.isdir(fallback_dir):
                for root, _dirs, files in os.walk(fallback_dir):
                    for fname in files:
                        if fname.lower().endswith(".mp4"):
                            existing_video_path = os.path.join(root, fname)
                            break
                    if existing_video_path:
                        break

            if existing_video_path:
                abs_existing = os.path.abspath(existing_video_path)
                logger.info(
                    "IG Fallback: found existing video at %s, returning it to client.",
                    abs_existing,
                )
                minimal_metadata: Dict[str, Any] = {
                    "shortcode": shortcode,
                    "source_url": str(payload.url),
                    "is_video": True,
                    "video_url": None,
                    "title": None,
                    "caption": None,
                    "upload_date": None,
                    "author_username": None,
                    "view_count": None,
                    "like_count": None,
                    "comment_count": None,
                    "thumbnail_url": None,
                    "local_file_name": os.path.basename(abs_existing),
                }
                return InstagramDownloadResponse(
                    file_path=abs_existing,
                    metadata=minimal_metadata,
                )
            else:
                logger.info(
                    "IG Fallback: no existing video file found for shortcode %s",
                    shortcode,
                )
        except Exception as fb_exc:  # noqa: BLE001
            logger.warning("IG fallback lookup failed: %s", fb_exc)

        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        logger.exception(
            "Unexpected server error while handling /instagram/download: %s", exc
        )
        raise HTTPException(status_code=500, detail="Internal server error") from exc


@app.post("/snapchat/download", response_model=SnapchatDownloadResponse, tags=["snapchat"])
async def snapchat_download_endpoint(
    payload: SnapchatDownloadRequest,
) -> SnapchatDownloadResponse:
    """
    Download a Snapchat video (direct URL) and return local path + metadata.
    """
    logger.info("SC Step 1: Received /snapchat/download request with URL=%s", payload.url)

    try:
        logger.info(
            "SC Step 2: Starting download into root folder: %s",
            SNAPCHAT_DOWNLOAD_ROOT,
        )
        video_path, metadata, _working_dir = download_snapchat_video(
            url=str(payload.url),
            output_dir=SNAPCHAT_DOWNLOAD_ROOT,
        )

        abs_path = os.path.abspath(video_path)
        logger.info("SC Step 3: Download finished. Local video path: %s", abs_path)
        logger.info("SC Step 4: Metadata keys: %s", list(metadata.keys()))

        response = SnapchatDownloadResponse(
            file_path=abs_path,
            metadata=metadata,
        )
        logger.info("SC Step 5: Returning successful Snapchat response to client.")
        return response

    except SnapchatDownloadError as exc:
        logger.error("Snapchat download error: %s", exc)
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        logger.exception(
            "Unexpected server error while handling /snapchat/download: %s", exc
        )
        raise HTTPException(status_code=500, detail="Internal server error") from exc

