#!/usr/bin/env python3
# 웹 페이지 fetch CLI — Reddit, 일반 웹 페이지 내용을 가져온다.
"""WebFetch 차단 도메인(Reddit 등)을 httpx로 직접 접근한다."""

import argparse
import json
import re
import sys


def ensure_httpx():
    """httpx 패키지 로드, 없으면 자동 설치."""
    try:
        import httpx
        return httpx
    except ImportError:
        import subprocess
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install",
             "--break-system-packages", "--user", "-q", "httpx"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        import httpx
        return httpx


def ensure_html2text():
    """html2text 패키지 로드, 없으면 자동 설치."""
    try:
        import html2text
        return html2text
    except ImportError:
        import subprocess
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install",
             "--break-system-packages", "--user", "-q", "html2text"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        import html2text
        return html2text


BROWSER_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
}


# ── Reddit ────────────────────────────────────────────────────


def is_reddit_url(url):
    """Reddit URL인지 판별."""
    return bool(re.match(r"https?://(www\.|old\.)?reddit\.com/", url))


def fetch_reddit(httpx, url, max_comments, timeout):
    """Reddit 게시글 + 댓글을 JSON API로 가져온다."""
    clean_url = url.rstrip("/")
    if not clean_url.endswith(".json"):
        clean_url += ".json"

    headers = {
        "User-Agent": BROWSER_HEADERS["User-Agent"],
        "Accept": "application/json",
    }

    r = httpx.get(
        clean_url, headers=headers,
        follow_redirects=True, timeout=timeout,
    )
    r.raise_for_status()
    data = r.json()

    # 게시글 추출
    post = data[0]["data"]["children"][0]["data"]
    result = {
        "title": post.get("title", ""),
        "author": post.get("author", ""),
        "subreddit": post.get("subreddit_name_prefixed", ""),
        "score": post.get("score", 0),
        "upvote_ratio": post.get("upvote_ratio", 0),
        "num_comments": post.get("num_comments", 0),
        "url": post.get("url", ""),
        "selftext": post.get("selftext", ""),
        "link_flair_text": post.get("link_flair_text", ""),
    }

    # 댓글 추출
    comments = []
    if len(data) > 1:
        _extract_comments(
            data[1]["data"]["children"],
            comments, max_comments,
        )

    result["comments"] = comments
    return result


def _extract_comments(children, out, limit, depth=0):
    """댓글을 재귀적으로 추출한다 (depth 표시 포함)."""
    for child in children:
        if len(out) >= limit:
            return
        if child["kind"] != "t1":
            continue
        cd = child["data"]
        out.append({
            "author": cd.get("author", ""),
            "score": cd.get("score", 0),
            "body": cd.get("body", ""),
            "depth": depth,
        })
        # 대댓글 재귀
        replies = cd.get("replies")
        if replies and isinstance(replies, dict):
            _extract_comments(
                replies["data"]["children"],
                out, limit, depth + 1,
            )


def fmt_reddit_md(data):
    """Reddit 데이터를 Markdown으로 포맷."""
    lines = []
    lines.append(f"# {data['title']}")
    lines.append(
        f"**{data['subreddit']}** · u/{data['author']}"
        f" · score: {data['score']} · 댓글: {data['num_comments']}"
    )
    lines.append("")

    if data["selftext"]:
        lines.append(data["selftext"])
        lines.append("")

    # 외부 링크가 있을 때만 표시
    post_url = data.get("url", "")
    if post_url and "reddit.com" not in post_url:
        lines.append(f"링크: {post_url}")
        lines.append("")

    if data["comments"]:
        lines.append("---")
        lines.append("## 댓글")
        lines.append("")
        for c in data["comments"]:
            indent = "  " * c["depth"]
            prefix = "> " * c["depth"]
            if c["depth"] == 0:
                lines.append(f"### u/{c['author']} (score: {c['score']})")
                lines.append(c["body"])
            else:
                lines.append(
                    f"{prefix}**u/{c['author']}** (score: {c['score']})"
                )
                lines.append(f"{prefix}{c['body']}")
            lines.append("")

    return "\n".join(lines)


# ── 일반 웹 페이지 ─────────────────────────────────────────────


def fetch_general(httpx, html2text, url, timeout):
    """일반 웹 페이지를 가져와서 Markdown 텍스트로 변환."""
    r = httpx.get(
        url, headers=BROWSER_HEADERS,
        follow_redirects=True, timeout=timeout,
    )
    r.raise_for_status()

    content_type = r.headers.get("content-type", "")

    # JSON 응답
    if "json" in content_type:
        return json.dumps(r.json(), ensure_ascii=False, indent=2)

    # HTML → Markdown 변환
    h = html2text.HTML2Text()
    h.ignore_links = False
    h.ignore_images = True
    h.body_width = 0
    h.ignore_emphasis = False

    text = h.handle(r.text)
    # 과도한 빈 줄 정리
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


# ── CLI ────────────────────────────────────────────────────────


def parse_args():
    p = argparse.ArgumentParser(description="웹 페이지 fetch CLI")
    p.add_argument("url", help="가져올 URL")
    p.add_argument(
        "-f", "--format", default="md",
        choices=["json", "md"],
        help="출력 형식 (기본: md)",
    )
    p.add_argument(
        "-c", "--max-comments", type=int, default=10,
        help="Reddit 최대 댓글 수 (기본: 10)",
    )
    p.add_argument(
        "--timeout", type=int, default=15,
        help="HTTP 타임아웃 초 (기본: 15)",
    )
    p.add_argument(
        "--max-length", type=int, default=0,
        help="최대 출력 글자 수 (0=무제한, 기본: 0)",
    )
    return p.parse_args()


def main():
    args = parse_args()
    httpx = ensure_httpx()

    try:
        if is_reddit_url(args.url):
            data = fetch_reddit(
                httpx, args.url,
                args.max_comments, args.timeout,
            )
            if args.format == "md":
                result = fmt_reddit_md(data)
            else:
                result = json.dumps(data, ensure_ascii=False, indent=2)
        else:
            html2text = ensure_html2text()
            result = fetch_general(httpx, html2text, args.url, args.timeout)
            if args.format == "json":
                result = json.dumps(
                    {"url": args.url, "content": result},
                    ensure_ascii=False, indent=2,
                )
    except Exception as e:
        print(f"Fetch 실패: {e}", file=sys.stderr)
        sys.exit(1)

    if args.max_length > 0:
        result = result[:args.max_length]

    print(result)


if __name__ == "__main__":
    main()
