#!/usr/bin/env python3
"""
YouTube 메타데이터 + 자막 추출

Usage:
    python extract_transcript.py <URL> [--output-dir DIR] [--lang LANG]

Examples:
    python extract_transcript.py "https://youtube.com/watch?v=xxx"
    python extract_transcript.py "https://youtube.com/watch?v=xxx" --output-dir ./subs
    python extract_transcript.py "https://youtube.com/watch?v=xxx" --lang en
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path


def extract_metadata(url: str) -> dict:
    """yt-dlp로 메타데이터 추출."""
    cmd = [
        "yt-dlp", "--dump-json", "--no-download", url,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"오류: 메타데이터 추출 실패\n{result.stderr}", file=sys.stderr)
        sys.exit(1)

    data = json.loads(result.stdout)
    return {
        "title": data.get("title", ""),
        "channel": data.get("channel", data.get("uploader", "")),
        "upload_date": data.get("upload_date", ""),
        "duration": data.get("duration_string", ""),
        "description": data.get("description", ""),
        "tags": data.get("tags", []),
    }


def extract_transcript(url: str, output_dir: str = ".", lang: str = "ko,en") -> str:
    """yt-dlp로 자막 추출 (JSON3 형식)."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    cmd = [
        "yt-dlp",
        "--write-auto-sub",
        "--sub-lang", lang,
        "--skip-download",
        "--convert-subs", "json3",
        "-o", str(output_dir / "%(title)s.%(ext)s"),
        url,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"경고: 자막 추출 실패\n{result.stderr}", file=sys.stderr)
        return ""

    return result.stdout


def main():
    parser = argparse.ArgumentParser(description="YouTube 메타데이터 + 자막 추출")
    parser.add_argument("url", help="YouTube URL")
    parser.add_argument("--output-dir", "-o", default=".", help="자막 저장 디렉토리 (기본: 현재)")
    parser.add_argument("--lang", "-l", default="ko,en", help="자막 언어 우선순위 (기본: ko,en)")
    parser.add_argument("--json", "-j", action="store_true", help="JSON 형식 출력")
    args = parser.parse_args()

    # 메타데이터 추출
    print("메타데이터 추출 중...", file=sys.stderr)
    metadata = extract_metadata(args.url)

    # 자막 추출
    print("자막 추출 중...", file=sys.stderr)
    extract_transcript(args.url, args.output_dir, args.lang)

    if args.json:
        print(json.dumps(metadata, ensure_ascii=False, indent=2))
    else:
        print(f"제목: {metadata['title']}")
        print(f"채널: {metadata['channel']}")
        print(f"업로드일: {metadata['upload_date']}")
        print(f"길이: {metadata['duration']}")
        if metadata['tags']:
            print(f"태그: {', '.join(metadata['tags'][:10])}")


if __name__ == "__main__":
    main()
