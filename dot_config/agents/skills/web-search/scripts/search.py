#!/usr/bin/env python3
# 원본 참고: https://github.com/bear2u/my-skills/tree/master/skills/web-search
"""DuckDuckGo 검색 CLI — ddgs v9.10+ API 기반."""

import argparse
import io
import json
import os
import sys
import time
from types import SimpleNamespace


# ── 국내 커뮤니티 프리셋 ──────────────────────────────────────
SITE_PRESETS = {
    "kr": [
        "clien.net", "fmkorea.com", "theqoo.net", "dcinside.com",
        "ruliweb.com", "ppomppu.co.kr", "todayhumor.co.kr", "82cook.com",
    ],
    "kr-dev": [
        "news.hada.io", "okky.kr", "disquiet.io", "careerly.co.kr",
    ],
    "kr-opinion": [
        "clien.net", "fmkorea.com", "theqoo.net", "dcinside.com",
        "82cook.com", "todayhumor.co.kr", "mlbpark.donga.com", "slrclub.com",
    ],
    "kr-career": [
        "blind.com", "careerly.co.kr", "okky.kr",
    ],
    "kr-auto": [
        "bobaedream.co.kr",
    ],
    "kr-game": [
        "inven.co.kr", "ruliweb.com",
    ],
}

SITE_LABELS = {
    "clien.net": "클리앙",
    "fmkorea.com": "에펨코리아",
    "theqoo.net": "더쿠",
    "dcinside.com": "디시인사이드",
    "ruliweb.com": "루리웹",
    "ppomppu.co.kr": "뽐뿌",
    "todayhumor.co.kr": "오늘의유머",
    "82cook.com": "82cook",
    "news.hada.io": "GeekNews",
    "okky.kr": "OKKY",
    "disquiet.io": "디스콰이엇",
    "careerly.co.kr": "커리어리",
    "mlbpark.donga.com": "MLB파크",
    "slrclub.com": "SLR클럽",
    "blind.com": "블라인드",
    "bobaedream.co.kr": "보배드림",
    "inven.co.kr": "인벤",
}


def ensure_ddgs():
    """ddgs (또는 duckduckgo_search) 패키지에서 DDGS를 로드하고, 없으면 자동 설치."""
    # ddgs 패키지 우선 시도 (신규 패키지명)
    try:
        from ddgs import DDGS
        return DDGS
    except ImportError:
        pass
    # 레거시 패키지명 폴백
    try:
        from duckduckgo_search import DDGS
        return DDGS
    except ImportError:
        pass
    # 자동 설치
    import subprocess
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install",
         "--break-system-packages", "--user", "-q", "ddgs"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    from ddgs import DDGS
    return DDGS


def parse_args():
    p = argparse.ArgumentParser(description="DuckDuckGo 검색 CLI")
    p.add_argument("query", help="검색어")
    p.add_argument("-t", "--type", default="text",
                   choices=["text", "news", "images", "videos"],
                   help="검색 타입 (기본: text)")
    p.add_argument("-n", "--max-results", type=int, default=10,
                   help="최대 결과 수 (기본: 10)")
    p.add_argument("-r", "--region", default="wt-wt",
                   help="지역 코드 (기본: wt-wt)")
    p.add_argument("-f", "--format", default="json",
                   choices=["json", "md"],
                   help="출력 형식 (기본: json)")
    p.add_argument("--fields", default=None,
                   help="출력 필드 (콤마 구분, 예: title,href)")
    p.add_argument("-p", "--timelimit", default=None,
                   choices=["d", "w", "m", "y"],
                   help="기간 필터 (d/w/m/y)")
    p.add_argument("-s", "--safesearch", default="moderate",
                   choices=["on", "moderate", "off"],
                   help="세이프서치 (기본: moderate)")
    p.add_argument("--timeout", type=int, default=10,
                   help="HTTP 타임아웃 초 (기본: 10)")
    p.add_argument("--page", type=int, default=1,
                   help="결과 페이지 (기본: 1)")
    p.add_argument("--sites", default=None,
                   help="프리셋 이름 또는 쉼표 구분 도메인 (+로 프리셋 결합)")
    p.add_argument("--per-site", type=int, default=3,
                   help="사이트별 최대 결과 수 (기본: 3)")
    p.add_argument("--site-delay", type=float, default=1.0,
                   help="사이트 간 딜레이 초 (기본: 1.0)")
    p.add_argument("--list-presets", action="store_true",
                   help="프리셋 목록 출력 후 종료")
    return p.parse_args()


def search_with_retry(fn, max_retries=3):
    """Rate limit 재시도 로직 (2/4/6초 간격)."""
    for attempt in range(max_retries):
        try:
            return fn()
        except Exception as e:
            err_str = str(e).lower()
            if "ratelimit" in err_str or "429" in err_str:
                if attempt < max_retries - 1:
                    wait = (attempt + 1) * 2
                    print(f"[재시도] Rate limit — {wait}초 대기 ({attempt + 1}/{max_retries})",
                          file=sys.stderr)
                    time.sleep(wait)
                    continue
            raise


def do_search(DDGS, args):
    """검색 타입별 DDGS 호출."""
    offset = (args.page - 1) * args.max_results

    # primp 라이브러리의 "Impersonate ... does not exist" 경고 억제
    _real_stderr = sys.stderr
    sys.stderr = io.StringIO()
    _real_stderr_fd = os.dup(2)
    _devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(_devnull, 2)

    try:
        return _do_search_inner(DDGS, args, offset)
    finally:
        # stderr 복원
        sys.stderr = _real_stderr
        os.dup2(_real_stderr_fd, 2)
        os.close(_real_stderr_fd)
        os.close(_devnull)


def _do_search_inner(DDGS, args, offset):
    """실제 검색 수행 (stderr 억제 상태에서 호출)."""
    with DDGS(timeout=args.timeout) as ddgs:
        common = dict(
            region=args.region,
            safesearch=args.safesearch,
            max_results=args.max_results + offset,
        )

        if args.type == "text":
            fn = lambda: list(ddgs.text(
                args.query, timelimit=args.timelimit, **common,
            ))
        elif args.type == "news":
            fn = lambda: list(ddgs.news(
                args.query, timelimit=args.timelimit, **common,
            ))
        elif args.type == "images":
            fn = lambda: list(ddgs.images(
                args.query, timelimit=args.timelimit, **common,
            ))
        elif args.type == "videos":
            fn = lambda: list(ddgs.videos(
                args.query, timelimit=args.timelimit, **common,
            ))
        else:
            print(f"알 수 없는 검색 타입: {args.type}", file=sys.stderr)
            sys.exit(1)

        results = search_with_retry(fn)

    # 페이지네이션: offset부터 슬라이싱
    if offset > 0:
        results = results[offset:]

    return results[:args.max_results]


def resolve_sites(sites_str):
    """문자열을 사이트 도메인 리스트로 변환."""
    if not sites_str:
        return None
    # + 구분자로 프리셋 결합
    if "+" in sites_str:
        seen = set()
        result = []
        for part in sites_str.split("+"):
            part = part.strip()
            domains = SITE_PRESETS.get(part, [part])
            for d in domains:
                if d not in seen:
                    seen.add(d)
                    result.append(d)
        return result
    # 프리셋 이름 단일
    if sites_str in SITE_PRESETS:
        return SITE_PRESETS[sites_str]
    # 쉼표 구분 도메인
    return [d.strip() for d in sites_str.split(",") if d.strip()]


def do_multi_site_search(DDGS, args, sites):
    """멀티사이트 검색: 각 사이트별 site: 쿼리로 검색 후 결과 병합."""
    all_results = []
    seen_urls = set()
    for i, domain in enumerate(sites):
        if i > 0:
            time.sleep(args.site_delay)
        # args 복사 후 쿼리/결과수 덮어쓰기
        site_args = SimpleNamespace(**vars(args))
        site_args.query = f"site:{domain} {args.query}"
        site_args.max_results = args.per_site
        site_args.page = 1
        label = SITE_LABELS.get(domain, domain)
        try:
            results = do_search(DDGS, site_args)
        except Exception as e:
            print(f"[경고] {label}({domain}) 검색 실패: {e}", file=sys.stderr)
            continue
        for r in results:
            # URL 기반 중복 제거
            url = r.get("href") or r.get("url") or ""
            if url in seen_urls:
                continue
            seen_urls.add(url)
            r["_site"] = domain
            r["_site_label"] = label
            all_results.append(r)
    return all_results[:args.max_results]


def fmt_multisite_md(results):
    """멀티사이트 전용 Markdown 포맷터."""
    lines = []
    for i, r in enumerate(results, 1):
        label = r.get("_site_label", "")
        title = r.get("title", "제목 없음")
        url = r.get("href", "")
        body = r.get("body", "")
        lines.append(f"## {i}. [{label}] {title}")
        if url:
            lines.append(url)
        if body:
            lines.append(f"> {body}")
        lines.append("")
    return "\n".join(lines)


def fmt_multisite_news_md(results):
    """멀티사이트 뉴스용 Markdown 포맷터 (날짜 포함)."""
    lines = []
    for i, r in enumerate(results, 1):
        label = r.get("_site_label", "")
        title = r.get("title", "제목 없음")
        date = r.get("date", "")
        url = r.get("url", r.get("href", ""))
        body = r.get("body", "")
        header = f"## {i}. [{label}] {title}"
        if date:
            header += f" ({date})"
        lines.append(header)
        if url:
            lines.append(url)
        if body:
            lines.append(f"> {body}")
        lines.append("")
    return "\n".join(lines)


def filter_fields(results, fields_str):
    """지정된 필드만 남긴다."""
    if not fields_str:
        return results
    fields = [f.strip() for f in fields_str.split(",")]
    return [{k: r.get(k) for k in fields if k in r} for r in results]


# ── Markdown 포맷터 ──────────────────────────────────────────

def fmt_text_md(results):
    lines = []
    for i, r in enumerate(results, 1):
        title = r.get("title", "제목 없음")
        url = r.get("href", "")
        body = r.get("body", "")
        lines.append(f"## {i}. {title}")
        if url:
            lines.append(url)
        if body:
            lines.append(f"> {body}")
        lines.append("")
    return "\n".join(lines)


def fmt_news_md(results):
    lines = []
    for i, r in enumerate(results, 1):
        title = r.get("title", "제목 없음")
        source = r.get("source", "")
        date = r.get("date", "")
        url = r.get("url", r.get("href", ""))
        body = r.get("body", "")
        meta = ", ".join(filter(None, [source, date]))
        header = f"## {i}. {title}"
        if meta:
            header += f" ({meta})"
        lines.append(header)
        if url:
            lines.append(url)
        if body:
            lines.append(f"> {body}")
        lines.append("")
    return "\n".join(lines)


def fmt_images_md(results):
    lines = []
    for i, r in enumerate(results, 1):
        title = r.get("title", "이미지")
        image = r.get("image", "")
        source = r.get("url", r.get("source", ""))
        lines.append(f"## {i}. {title}")
        if image:
            lines.append(image)
        if source:
            lines.append(f"Source: {source}")
        lines.append("")
    return "\n".join(lines)


def fmt_videos_md(results):
    lines = []
    for i, r in enumerate(results, 1):
        title = r.get("title", "영상")
        url = r.get("content", r.get("href", ""))
        desc = r.get("description", "")
        duration = r.get("duration", "")
        publisher = r.get("publisher", "")
        meta = ", ".join(filter(None, [duration, publisher]))
        header = f"## {i}. {title}"
        if meta:
            header += f" ({meta})"
        lines.append(header)
        if url:
            lines.append(url)
        if desc:
            lines.append(f"> {desc}")
        lines.append("")
    return "\n".join(lines)


MD_FORMATTERS = {
    "text": fmt_text_md,
    "news": fmt_news_md,
    "images": fmt_images_md,
    "videos": fmt_videos_md,
}


def output(results, args, multisite=False):
    """결과 출력 (JSON 또는 Markdown)."""
    results = filter_fields(results, args.fields)

    if not results:
        print("검색 결과 없음.", file=sys.stderr)
        sys.exit(0)

    if args.format == "md":
        if multisite:
            if args.type == "news":
                formatter = fmt_multisite_news_md
            else:
                formatter = fmt_multisite_md
        else:
            formatter = MD_FORMATTERS[args.type]
        print(formatter(results))
    else:
        print(json.dumps(results, ensure_ascii=False, indent=2))


def main():
    args = parse_args()

    # 프리셋 목록 출력
    if args.list_presets:
        print("사용 가능한 프리셋:")
        for name, domains in SITE_PRESETS.items():
            labels = [f"{SITE_LABELS.get(d, d)}" for d in domains]
            print(f"  {name}: {', '.join(labels)}")
        sys.exit(0)

    DDGS = ensure_ddgs()
    sites = resolve_sites(args.sites)

    if sites:
        # 멀티사이트: text/news만 지원
        if args.type not in ("text", "news"):
            print(f"멀티사이트 검색은 text/news만 지원합니다 (현재: {args.type})",
                  file=sys.stderr)
            sys.exit(1)
        try:
            results = do_multi_site_search(DDGS, args, sites)
        except Exception as e:
            print(f"검색 실패: {e}", file=sys.stderr)
            sys.exit(1)
        output(results, args, multisite=True)
    else:
        try:
            results = do_search(DDGS, args)
        except Exception as e:
            print(f"검색 실패: {e}", file=sys.stderr)
            sys.exit(1)
        output(results, args)


if __name__ == "__main__":
    main()
