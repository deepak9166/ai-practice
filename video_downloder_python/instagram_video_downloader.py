#!/usr/bin/env python
"""
Instagram Video Downloader & Uploader CLI

Dependencies (install with pip):
    pip install instaloader requests

Usage examples:

    # Basic download only, prints metadata as JSON
    python instagram_video_downloader.py "https://www.instagram.com/p/SHORTCODE/"

    # Download and upload to a custom API with Bearer token
    python instagram_video_downloader.py \
        "https://www.instagram.com/p/SHORTCODE/" \
        --api-url "https://api.example.com/upload" \
        --api-token "YOUR_API_TOKEN"

    # Using Instagram login (e.g., for private content you can access)
    python instagram_video_downloader.py \
        "https://www.instagram.com/p/SHORTCODE/" \
        --ig-username "your_ig_username" \
        --ig-password "your_ig_password"

    # Keep the downloaded file instead of cleaning it up
    python instagram_video_downloader.py "https://www.instagram.com/p/SHORTCODE/" --keep-file
"""

import argparse
import json
import logging
import os
import re
import shutil
import sys
import tempfile
from datetime import datetime
from typing import Any, Dict, Optional, Tuple

import requests

try:
    import instaloader
except ImportError as exc:  # pragma: no cover - import-time failure
    print(
        "Error: 'instaloader' package is required. "
        "Install it with: pip install instaloader",
        file=sys.stderr,
    )
    raise


logger = logging.getLogger(__name__)


class InstagramDownloadError(Exception):
    """Raised when downloading the Instagram video fails."""


class APIUploadError(Exception):
    """Raised when uploading to the custom API fails."""


def _sanitize_filename(name: str, fallback: str) -> str:
    """
    Make a safe filename for the local filesystem, based on the post title.

    - Removes characters that are invalid on Windows (<>:\"/\\|?*)
    - Strips leading/trailing spaces and dots
    - Falls back to `fallback` if the result is empty
    """
    if not name:
        return fallback

    # Replace path separators and other illegal characters
    illegal_chars = '<>:"/\\\\|?*'
    for ch in illegal_chars:
        name = name.replace(ch, " ")

    # Collapse whitespace
    name = re.sub(r"\s+", " ", name).strip(" .")

    return name or fallback


def parse_instagram_url(url: str) -> str:
    """
    Parse an Instagram post URL and extract the shortcode.

    Supports typical forms like:
        https://www.instagram.com/p/SHORTCODE/
        https://www.instagram.com/reel/SHORTCODE/
        https://instagram.com/tv/SHORTCODE/?utm_source=...

    Returns:
        The post shortcode string.

    Raises:
        ValueError: If the URL does not look like a valid Instagram post URL.
    """
    if not isinstance(url, str) or not url.strip():
        raise ValueError("Instagram URL must be a non-empty string.")

    # Normalize
    url = url.strip()

    # Regex to capture shortcode between known path segments
    pattern = re.compile(
        r"https?://(?:www\.)?instagram\.com/"
        r"(?:p|reel|tv)/"  # post types
        r"(?P<shortcode>[^/?#]+)",  # capture until next / ? or #
        re.IGNORECASE,
    )
    match = pattern.search(url)
    if not match:
        raise ValueError(f"Could not extract shortcode from URL: {url}")

    shortcode = match.group("shortcode")
    if not shortcode:
        raise ValueError(f"Invalid Instagram URL, missing shortcode: {url}")
    return shortcode


def init_instaloader(
    ig_username: Optional[str] = None,
    ig_password: Optional[str] = None,
    sessionfile: Optional[str] = None,
    filename_pattern: Optional[str] = None,
) -> "instaloader.Instaloader":
    """
    Initialize and optionally authenticate an Instaloader instance.

    Authentication is helpful for:
        - Accessing private posts you are allowed to see
        - Reducing the chance of being rate-limited

    Args:
        ig_username: Instagram username for login.
        ig_password: Instagram password for login.
        sessionfile: Optional path to an existing Instaloader session file.

    Returns:
        An initialized Instaloader instance.

    Raises:
        InstagramDownloadError: If login fails.
    """
    loader = instaloader.Instaloader(
        download_videos=True,
        download_video_thumbnails=True,
        download_geotags=False,
        download_comments=False,
        save_metadata=False,
        compress_json=False,
        post_metadata_txt_pattern="",
        dirname_pattern="",
        filename_pattern=filename_pattern,
    )

    try:
        if sessionfile:
            logger.debug("Loading Instaloader session from %s", sessionfile)
            loader.load_session_from_file(ig_username or "", sessionfile)
        elif ig_username and ig_password:
            logger.debug("Logging in to Instagram as %s", ig_username)
            loader.login(ig_username, ig_password)
        else:
            logger.debug("Using Instaloader without authentication.")
    except Exception as exc:  # noqa: BLE001
        raise InstagramDownloadError(f"Failed to authenticate with Instagram: {exc}") from exc

    return loader


def download_instagram_video(
    url: str,
    output_dir: Optional[str] = None,
    ig_username: Optional[str] = None,
    ig_password: Optional[str] = None,
    sessionfile: Optional[str] = None,
) -> Tuple[str, Dict[str, Any], str]:
    """
    Download an Instagram video and extract its metadata.

    Args:
        url: Instagram post URL.
        output_dir: Directory where the video will be stored. If None, a
            temporary directory will be created.
        ig_username: Optional Instagram username for login.
        ig_password: Optional Instagram password for login.
        sessionfile: Optional path to an Instaloader session file.

    Returns:
        (video_file_path, metadata_dict, working_dir)

        - video_file_path: path to the downloaded .mp4 file.
        - metadata_dict: JSON-serializable dictionary with post metadata.
        - working_dir: directory that contains the downloaded file(s).

    Raises:
        InstagramDownloadError: On any failure to download or locate the video.
    """

    logger.info(" START LOADDER %s", url )
    shortcode = parse_instagram_url(url)

    logger.info("SHORT CODE FOUND %s", shortcode )
    loader = init_instaloader(ig_username, ig_password, sessionfile,shortcode)

    logger.info("LOADER INITIALIZED %s", loader)
    # Prepare working directory
    if output_dir is None:
        working_dir = tempfile.mkdtemp(prefix="ig_video_")
        logger.debug("Created temporary directory: %s", working_dir)
    else:
        working_dir = output_dir
        os.makedirs(working_dir, exist_ok=True)

    try:
        logger.info("Fetching Instagram post metadata for shortcode %s", shortcode)
        post = instaloader.Post.from_shortcode(loader.context, shortcode)
        logger.info("POST FOUND %s", post)
        if not post.is_video:
            raise InstagramDownloadError("The provided post is not a video.")

        # Clean up any legacy files downloaded directly into working_dir
        # with the old date_utc + shortcode pattern, so new logic can create
        # a fresh, title-based filename.
        try:
            for fname in os.listdir(working_dir):
                if not fname.lower().endswith(".mp4"):
                    continue
                if shortcode in fname and "utc" in fname.lower():
                    legacy_path = os.path.join(working_dir, fname)
                    logger.info("Removing legacy video file: %s", legacy_path)
                    try:
                        os.remove(legacy_path)
                    except OSError as rem_exc:
                        logger.warning(
                            "Could not remove legacy file %s: %s", legacy_path, rem_exc
                        )
        except FileNotFoundError:
            pass

        # Download into a predictable subfolder under working_dir by temporarily
        # changing the current working directory. This avoids Instaloader creating
        # a folder whose *name* is the full absolute path string.
        target_dir = os.path.join(working_dir, shortcode)
        os.makedirs(target_dir, exist_ok=True)

        logger.info("Downloading video into folder %s", target_dir)
        old_cwd = os.getcwd()
        try:
            os.chdir(working_dir)
            # Instaloader will create a folder named `shortcode` inside working_dir
            # because dirname_pattern is left as default / {target}.
            loader.download_post(post, target=shortcode)
        finally:
            os.chdir(old_cwd)

        # Find the downloaded .mp4 file inside working_dir/shortcode
        video_file_path = None
        for root, _dirs, files in os.walk(target_dir):
            for fname in files:
                if fname.lower().endswith(".mp4"):
                    video_file_path = os.path.join(root, fname)
                    break
            if video_file_path:
                break

        # if not video_file_path:
        #     raise InstagramDownloadError("Video file was not found after download.")

        # Extract metadata into a JSON-serializable dict
        title_from_post = getattr(post, "title", None)
        safe_title = _sanitize_filename(title_from_post or shortcode, fallback=shortcode)

        # Rename file so it uses the (sanitized) title in the filename
        new_filename = f"{safe_title}_{shortcode}.mp4"
        new_video_path = os.path.join(os.path.dirname(video_file_path), new_filename)
        if os.path.abspath(new_video_path) != os.path.abspath(video_file_path):
            try:
                os.replace(video_file_path, new_video_path)
                video_file_path = new_video_path
            except OSError as rename_exc:
                logger.warning("Could not rename video file to use title: %s", rename_exc)

        metadata: Dict[str, Any] = {
            "shortcode": shortcode,
            "source_url": url,
            "is_video": post.is_video,
            "video_url": getattr(post, "video_url", None),
            "title": title_from_post,
            "caption": post.caption,
            "upload_date": post.date_utc.isoformat() if isinstance(post.date_utc, datetime) else None,
            "author_username": post.owner_username,
            "view_count": getattr(post, "video_view_count", None),
            "like_count": getattr(post, "likes", None),
            "comment_count": getattr(post, "comments", None),
            "thumbnail_url": getattr(post, "url", None),
            "local_file_name": os.path.basename(video_file_path),
        }

        return video_file_path, metadata, working_dir
    except InstagramDownloadError:
        raise
    except Exception as exc:  # noqa: BLE001
        # Best-effort fallback: if the video file actually exists on disk
        # (for example, from a previous successful download) but Instaloader
        # now fails due to rate limiting / 403, return minimal metadata
        # instead of failing the whole request.
        try:
            target_dir = os.path.join(working_dir, shortcode)
            video_file_path = None
            for root, _dirs, files in os.walk(target_dir):
                for fname in files:
                    if fname.lower().endswith(".mp4"):
                        video_file_path = os.path.join(root, fname)
                        break
                if video_file_path:
                    break

            if video_file_path:
                logger.warning(
                    "Instaloader failed (%s) but video file exists at %s. "
                    "Returning minimal metadata.",
                    exc,
                    video_file_path,
                )
                metadata = {
                    "shortcode": shortcode,
                    "source_url": url,
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
                }
                return video_file_path, metadata, working_dir
        except Exception:  # noqa: BLE001
            # Ignore any fallback-specific errors and fall through
            pass

        raise InstagramDownloadError(f"Failed to download Instagram video: {exc}") from exc


def upload_to_api(
    file_path: str,
    metadata: Dict[str, Any],
    api_url: str,
    api_token: Optional[str] = None,
    verify_ssl: bool = True,
    timeout: int = 60,
) -> requests.Response:
    """
    Upload the video file and its metadata to a custom API endpoint.

    The request is sent as multipart/form-data with:
        - file: the video file
        - metadata: a JSON string of the metadata dictionary

    Args:
        file_path: Path to the video file to upload.
        metadata: Metadata dictionary to send along with the file.
        api_url: API endpoint URL.
        api_token: Optional Bearer token for Authorization header.
        verify_ssl: Whether to verify SSL certificates.
        timeout: Request timeout in seconds.

    Returns:
        The `requests.Response` object.

    Raises:
        APIUploadError: If the upload fails for any reason.
    """
    if not api_url:
        raise APIUploadError("API URL must be provided.")

    if not os.path.isfile(file_path):
        raise APIUploadError(f"Video file does not exist: {file_path}")

    headers = {}
    if api_token:
        headers["Authorization"] = f"Bearer {api_token}"

    files = {
        "file": (
            os.path.basename(file_path),
            open(file_path, "rb"),
            "video/mp4",
        )
    }
    data = {
        "metadata": json.dumps(metadata, ensure_ascii=False),
    }

    try:
        logger.info("Uploading video to API: %s", api_url)
        response = requests.post(
            api_url,
            headers=headers,
            files=files,
            data=data,
            timeout=timeout,
            verify=verify_ssl,
        )
    except requests.RequestException as exc:
        raise APIUploadError(f"API request failed: {exc}") from exc
    finally:
        # Ensure file handle is closed
        files["file"][1].close()

    if not (200 <= response.status_code < 300):
        raise APIUploadError(
            f"API responded with status {response.status_code}: {response.text[:500]}"
        )

    return response


def cleanup_directory(path: str) -> None:
    """
    Recursively delete a directory, ignoring errors.
    """
    if not path:
        return
    if not os.path.exists(path):
        return
    try:
        shutil.rmtree(path)
        logger.debug("Removed temporary directory: %s", path)
    except Exception as exc:  # noqa: BLE001
        logger.warning("Failed to remove directory %s: %s", path, exc)


def build_arg_parser() -> argparse.ArgumentParser:
    """
    Build the argument parser for the CLI.
    """
    parser = argparse.ArgumentParser(
        description="Download Instagram videos and optionally upload them to a custom API.",
    )
    parser.add_argument(
        "url",
        help="Instagram video URL (e.g., https://www.instagram.com/p/SHORTCODE/).",
    )

    # Instagram auth
    parser.add_argument(
        "--ig-username",
        help="Instagram username for login (optional).",
    )
    parser.add_argument(
        "--ig-password",
        help="Instagram password for login (optional; use with care).",
    )
    parser.add_argument(
        "--ig-sessionfile",
        help="Path to an Instaloader session file (optional).",
    )

    # API upload options
    parser.add_argument(
        "--api-url",
        help="Custom API endpoint URL for uploading the video (optional).",
    )
    parser.add_argument(
        "--api-token",
        help="Authentication token (Bearer) for the API (optional).",
    )
    parser.add_argument(
        "--no-verify-ssl",
        action="store_true",
        help="Disable SSL verification for API requests (not recommended).",
    )
    parser.add_argument(
        "--api-timeout",
        type=int,
        default=60,
        help="Timeout in seconds for API requests (default: 60).",
    )

    # Misc options
    parser.add_argument(
        "--output-dir",
        help="Directory to store downloaded files (optional; temp dir is used by default).",
    )
    parser.add_argument(
        "--keep-file",
        action="store_true",
        help="Do not delete the downloaded video/temporary files after completion.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose logging.",
    )

    return parser


def configure_logging(verbose: bool) -> None:
    """
    Configure basic logging for the script.
    """
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )


def main(argv: Optional[list[str]] = None) -> int:
    """
    Main entry point for the command-line interface.

    Returns:
        Exit code (0 on success, non-zero on failure).
    """
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    configure_logging(args.verbose)

    logger.debug("Parsed arguments: %s", args)

    video_path: Optional[str] = None
    working_dir: Optional[str] = None

    try:
        video_path, metadata, working_dir = download_instagram_video(
            url=args.url,
            output_dir=args.output_dir,
            ig_username=args.ig_username,
            ig_password=args.ig_password,
            sessionfile=args.ig_sessionfile,
        )

        # Print metadata as pretty JSON for visibility
        print(json.dumps(metadata, indent=2, ensure_ascii=False))

        # Optionally upload to a custom API
        if args.api_url:
            response = upload_to_api(
                file_path=video_path,
                metadata=metadata,
                api_url=args.api_url,
                api_token=args.api_token,
                verify_ssl=not args.no_verify_ssl,
                timeout=args.api_timeout,
            )
            logger.info(
                "Upload successful (status %s). Response snippet: %s",
                response.status_code,
                response.text[:500],
            )

        return 0

    except (ValueError, InstagramDownloadError, APIUploadError) as exc:
        logger.error("%s", exc)
        return 1
    except KeyboardInterrupt:
        logger.error("Interrupted by user.")
        return 130
    finally:
        # Clean up temporary data if requested
        if not args.keep_file and working_dir and not args.output_dir:
            cleanup_directory(working_dir)


if __name__ == "__main__":
    sys.exit(main())

