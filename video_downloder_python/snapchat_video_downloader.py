#!/usr/bin/env python
"""
Snapchat Video Downloader helper.

This is intentionally simpler than the Instagram version: it assumes you give
it a direct video URL that can be fetched with plain HTTP (no auth, no DRM).
"""

import json
import logging
import os
import re
import tempfile
from datetime import datetime
from typing import Any, Dict, Optional, Tuple
from urllib.parse import urlparse, urlunparse

import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)


class SnapchatDownloadError(Exception):
    """Raised when downloading the Snapchat video fails."""


def _sanitize_filename(name: str, fallback: str) -> str:
    """
    Make a safe filename for the local filesystem.
    """
    if not name:
        return fallback

    illegal_chars = '<>:"/\\\\|?*'
    for ch in illegal_chars:
        name = name.replace(ch, " ")

    name = re.sub(r"\s+", " ", name).strip(" .")
    return name or fallback


def _extract_direct_video_url_from_html(html: str) -> Optional[str]:
    """
    Extract a direct video URL from a Snapchat page HTML.

    Snapchat renders video tags via JavaScript, so they are not in the raw HTML.
    Instead, the video URL is embedded in the __NEXT_DATA__ JSON blob.

    Path: props.pageProps.spotlightFeed.spotlightStories[0].story.snapList[0].snapUrls.mediaUrl
    """
    soup = BeautifulSoup(html, "html.parser")

    # 1) Extract from __NEXT_DATA__ JSON (primary method)
    script_tag = soup.find("script", attrs={"id": "__NEXT_DATA__"})
    if script_tag and script_tag.string:
        try:
            data = json.loads(script_tag.string)
            stories = (
                data.get("props", {})
                .get("pageProps", {})
                .get("spotlightFeed", {})
                .get("spotlightStories", [])
            )
            if stories:
                media_url = (
                    stories[0]
                    .get("story", {})
                    .get("snapList", [{}])[0]
                    .get("snapUrls", {})
                    .get("mediaUrl")
                )
                if media_url:
                    logger.info("Found video URL via __NEXT_DATA__")
                    return media_url
        except (json.JSONDecodeError, IndexError, KeyError) as exc:
            logger.warning("Failed to parse __NEXT_DATA__: %s", exc)

    # 2) Fallback: <source src="..." type="video/mp4">
    source_tag = soup.find("source", attrs={"type": "video/mp4"})
    if source_tag and source_tag.get("src"):
        logger.info("Found video URL via <source> tag")
        return source_tag["src"]

    # 3) Fallback: Any <video> tag with src
    video_tag = soup.find("video")
    if video_tag and video_tag.get("src"):
        logger.info("Found video URL via <video> tag")
        return video_tag["src"]

    return None


def _resolve_snapchat_video_url(url: str) -> Tuple[str, Optional[str]]:
    """
    Given a Snapchat share/page URL, try to resolve:
      - the direct video URL
      - the page title (from og:title) for file naming
    """
    logger.info("Resolving Snapchat direct video URL from %s", url)
    params = {
        "share_id": "5gUjk59mtAs",
        "locale": "en-IN",
    }
    try:
        headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept-Language": "en-US,en;q=0.9"
}

        resp = requests.get(url, headers=headers, timeout=30)
        # logger.info("RESPONSE FOUND %s", resp.content)
    except requests.RequestException as exc:
        raise SnapchatDownloadError(f"Failed to fetch Snapchat page: {exc}") from exc

    if not (200 <= resp.status_code < 300):
        raise SnapchatDownloadError(
            f"Failed to fetch Snapchat page. HTTP {resp.status_code}"
        )

    html = resp.text or ""

    # Extract page title for naming from og:title
    soup = BeautifulSoup(html, "html.parser")
    title_tag = soup.find("meta", attrs={"property": "og:title"})
    page_title: Optional[str] = None
    if title_tag and title_tag.get("content"):
        page_title = title_tag["content"]
        logger.info("Resolved Snapchat page title: %s", page_title)

    direct_url = _extract_direct_video_url_from_html(html)
    logger.info("DIRECT URL FOUND %s", direct_url)
    if not direct_url:
        raise SnapchatDownloadError(
            "Could not find a direct video URL in the Snapchat page HTML."
        )

    logger.info("Resolved Snapchat direct video URL: %s", direct_url)
    return direct_url, page_title


def download_snapchat_video(
    url: str,
    output_dir: Optional[str] = None,
) -> Tuple[str, Dict[str, Any], str]:
    """
    Download a Snapchat video.

    Args:
        url: Either a direct video URL (mp4, etc.) or a public Snapchat share URL.
        output_dir: Directory where the video will be stored. If None, a
            temporary directory will be created.

    Returns:
        (video_file_path, metadata_dict, working_dir)
    """
    if not isinstance(url, str) or not url.strip():
        raise SnapchatDownloadError("Snapchat URL must be a non-empty string.")

    # Normalize input and strip query parameters (share_id, locale, etc.)
    raw_url = url.strip()
    parsed = urlparse(raw_url)
    stripped_url = urlunparse((parsed.scheme, parsed.netloc, parsed.path, "", "", ""))

    # Always resolve via HTML scraping so we consistently extract:
    #  - the media URL
    #  - the page title (for file naming)
    direct_url, page_title = _resolve_snapchat_video_url(stripped_url)

    # Prepare working directory
    if output_dir is None:
        working_dir = tempfile.mkdtemp(prefix="snap_video_")
        logger.debug("Created temporary Snapchat temp directory: %s", working_dir)
    else:
        working_dir = output_dir
        os.makedirs(working_dir, exist_ok=True)

    try:
        logger.info("Downloading Snapchat video from %s", direct_url)
        resp = requests.get(direct_url, stream=True, timeout=60)
        if not (200 <= resp.status_code < 300):
            raise SnapchatDownloadError(
                f"Failed to download Snapchat video. HTTP {resp.status_code}"
            )

        # Guess extension from content-type or URL
        content_type = resp.headers.get("Content-Type", "")
        ext = ".mp4"
        if "quicktime" in content_type or "mov" in direct_url.lower():
            ext = ".mov"

        ts = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
        # Build a short, readable name. Prefer the username in (@username)
        # from the title if present, otherwise a truncated title.
        raw_name = page_title or "snapchat_video"
        m = re.search(r"\(@([^)]*)\)", raw_name)
        if m and m.group(1):
            raw_name = m.group(1)
        else:
            raw_name = raw_name[:30]
        base_name = _sanitize_filename(raw_name, fallback="snapchat_video")
        file_name = f"{base_name}_{ts}.mp4"
        file_path = os.path.join(working_dir, file_name)

        with open(file_path, "wb") as f:
            for chunk in resp.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

        size_bytes = os.path.getsize(file_path)

        metadata: Dict[str, Any] = {
            "source_url": stripped_url,
            "downloaded_at_utc": datetime.utcnow().isoformat(),
            "file_name": file_name,
            "file_size_bytes": size_bytes,
            "content_type": content_type or None,
            "page_title": page_title,
        }

        return file_path, metadata, working_dir

    except SnapchatDownloadError:
        raise
    except requests.RequestException as exc:
        raise SnapchatDownloadError(
            f"Network error while downloading Snapchat video: {exc}"
        ) from exc
    except Exception as exc:  # noqa: BLE001
        raise SnapchatDownloadError(f"Failed to download Snapchat video: {exc}") from exc





# https://www.snapchat.com/spotlight/W7_EDlXWTBiXAEEniNoMPwAAYeGhraHdoeXp1AZyznY5qAZyznY5NAAAAAw?share_id=5gUjk59mtAs&locale=en-IN


# https://www.snapchat.com/@prince_soni1000/spotlight/W7_EDlXWTBiXAEEniNoMPwAAYeGhraHdoeXp1AZyznY5qAZyznY5NAAAAAw?share_id=5gUjk59mtAs&locale=en-IN


# https://www.snapchat.com/@prince_soni1000/spotlight/W7_EDlXWTBiXAEEniNoMPwAAYeGhraHdoeXp1AZyznY5qAZyznY5NAAAAAw