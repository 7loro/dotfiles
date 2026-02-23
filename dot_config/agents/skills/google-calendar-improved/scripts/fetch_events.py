"""Google Calendar 이벤트 조회 스크립트.

사용법:
    uv run python scripts/fetch_events.py --account work --days 7
    uv run python scripts/fetch_events.py --account work --start 2026-02-18 --end 2026-02-25
    uv run python scripts/fetch_events.py --account work --days 1 --json
    uv run python scripts/fetch_events.py --account work --query "미팅"
"""

import argparse
import json
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

sys.path.insert(0, str(Path(__file__).resolve().parent))

from calendar_client import (
    DEFAULT_TIMEZONE,
    format_event_time,
    get_calendar_service,
    get_event_sort_key,
    load_config,
)

# 요일 한글
WEEKDAYS = ["월", "화", "수", "목", "금", "토", "일"]


def filter_excluded(events: list[dict], account_name: str) -> list[dict]:
    """accounts.yaml의 exclude_allday 설정에 따라 종일 이벤트를 필터링한다."""
    try:
        config = load_config()
    except FileNotFoundError:
        return events

    account_cfg = config.get("accounts", {}).get(account_name, {})
    exclude_patterns = account_cfg.get("exclude_allday", [])
    if not exclude_patterns:
        return events

    # 대소문자 무시 비교용
    patterns_lower = [p.lower() for p in exclude_patterns]

    return [
        e for e in events
        if not (
            "date" in e.get("start", {})
            and e.get("summary", "").lower() in patterns_lower
        )
    ]


def main():
    parser = argparse.ArgumentParser(description="Google Calendar 이벤트 조회")
    parser.add_argument("--account", required=True, help="계정 이름")
    parser.add_argument("--days", type=int, default=7, help="조회 기간 (일, 기본: 7)")
    parser.add_argument("--start", help="시작 날짜 (YYYY-MM-DD, --days 대신 사용)")
    parser.add_argument("--end", help="종료 날짜 (YYYY-MM-DD, --start와 함께 사용)")
    parser.add_argument("--query", help="일정 검색어")
    parser.add_argument("--max", type=int, default=100, help="최대 조회 수 (기본: 100)")
    parser.add_argument("--json", action="store_true", dest="json_output", help="JSON 형식 출력")
    parser.add_argument("--timezone", default=DEFAULT_TIMEZONE, help=f"타임존 (기본: {DEFAULT_TIMEZONE})")
    args = parser.parse_args()

    try:
        service = get_calendar_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    # 조회 기간 계산
    tz = ZoneInfo(args.timezone)
    if args.start:
        time_min = datetime.strptime(args.start, "%Y-%m-%d").replace(tzinfo=tz)
        if args.end:
            time_max = datetime.strptime(args.end, "%Y-%m-%d").replace(tzinfo=tz)
        else:
            time_max = time_min + timedelta(days=args.days)
    else:
        now = datetime.now(tz)
        time_min = now.replace(hour=0, minute=0, second=0, microsecond=0)
        time_max = time_min + timedelta(days=args.days)

    # API 호출
    list_params = {
        "calendarId": "primary",
        "timeMin": time_min.isoformat(),
        "timeMax": time_max.isoformat(),
        "maxResults": args.max,
        "singleEvents": True,
        "orderBy": "startTime",
    }
    if args.query:
        list_params["q"] = args.query

    try:
        events = []
        page_token = None
        while True:
            if page_token:
                list_params["pageToken"] = page_token
            result = service.events().list(**list_params).execute()
            events.extend(result.get("items", []))
            page_token = result.get("nextPageToken")
            if not page_token or len(events) >= args.max:
                break
    except Exception as e:
        print(f"API 오류: {e}", file=sys.stderr)
        sys.exit(1)

    # 계정별 제외 패턴 적용
    events = filter_excluded(events, args.account)

    if not events:
        print("일정이 없습니다.")
        return

    # 출력
    if args.json_output:
        print_json(events, args.account)
    else:
        print_events(events, args.account, args.timezone)


def print_json(events: list[dict], account: str):
    """JSON 형식으로 출력한다."""
    results = []
    for event in events:
        start_time, end_time = format_event_time(event)
        entry = {
            "id": event.get("id", ""),
            "summary": event.get("summary", "(제목 없음)"),
            "start": start_time,
            "end": end_time,
            "location": event.get("location", ""),
            "description": event.get("description", ""),
            "status": event.get("status", ""),
            "htmlLink": event.get("htmlLink", ""),
            "account": account,
            "isAllDay": "date" in event.get("start", {}),
            "attendees": [
                {
                    "email": a.get("email", ""),
                    "responseStatus": a.get("responseStatus", ""),
                }
                for a in event.get("attendees", [])
            ],
        }
        results.append(entry)
    print(json.dumps(results, ensure_ascii=False, indent=2))


def print_events(events: list[dict], account: str, timezone: str):
    """이벤트를 날짜별로 보기 좋게 출력한다."""
    tz = ZoneInfo(timezone)

    # 날짜별로 그룹핑
    by_date: dict[str, list[dict]] = defaultdict(list)
    for event in events:
        start = event.get("start", {})
        if "date" in start:
            date_key = start["date"]
        else:
            dt = datetime.fromisoformat(start["dateTime"]).astimezone(tz)
            date_key = dt.strftime("%Y-%m-%d")
        by_date[date_key].append(event)

    total_events = len(events)
    total_allday = sum(1 for e in events if "date" in e.get("start", {}))

    for date_str in sorted(by_date.keys()):
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        weekday = WEEKDAYS[date_obj.weekday()]
        print(f"\n📅 {date_str} ({weekday}) 일정")
        print()

        day_events = by_date[date_str]
        # 시간순 정렬 (종일 이벤트 먼저)
        day_events.sort(key=get_event_sort_key)

        for event in day_events:
            summary = event.get("summary", "(제목 없음)")
            start_time, end_time = format_event_time(event)
            location = event.get("location", "")

            if "date" in event.get("start", {}):
                print(f"  [종일] {summary} ({account})")
            else:
                print(f"  [{start_time}-{end_time}] {summary} ({account})")

            if location:
                print(f"         📍 {location}")

            # 참석자 표시
            attendees = event.get("attendees", [])
            if attendees:
                names = []
                for a in attendees[:5]:
                    email = a.get("email", "")
                    status_icon = {
                        "accepted": "✅",
                        "declined": "❌",
                        "tentative": "❓",
                        "needsAction": "⏳",
                    }.get(a.get("responseStatus", ""), "")
                    names.append(f"{status_icon}{email}")
                extra = f" 외 {len(attendees) - 5}명" if len(attendees) > 5 else ""
                print(f"         👥 {', '.join(names)}{extra}")

            print(f"         🔗 ID: {event.get('id', '')}")

    print(f"\n📊 총 {total_events}개 일정 (종일: {total_allday}, 시간: {total_events - total_allday})")


if __name__ == "__main__":
    main()
