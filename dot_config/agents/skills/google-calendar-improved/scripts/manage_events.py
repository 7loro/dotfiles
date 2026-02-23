"""Google Calendar 이벤트 생성/수정/삭제 스크립트.

사용법:
    # 시간 지정 일정 생성
    uv run python scripts/manage_events.py create \
        --summary "팀 미팅" \
        --start "2026-01-06T14:00:00" \
        --end "2026-01-06T15:00:00" \
        --account work

    # 종일 일정 생성
    uv run python scripts/manage_events.py create \
        --summary "연차" \
        --start "2026-01-10" \
        --end "2026-01-11" \
        --account personal

    # 일정 수정
    uv run python scripts/manage_events.py update \
        --event-id "abc123" \
        --summary "팀 미팅 (변경)" \
        --start "2026-01-06T15:00:00" \
        --account work

    # 일정 삭제
    uv run python scripts/manage_events.py delete \
        --event-id "abc123" \
        --account work
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from calendar_client import (
    DEFAULT_TIMEZONE,
    build_event_body,
    format_event_time,
    get_calendar_service,
    parse_datetime,
)


def main():
    parser = argparse.ArgumentParser(description="Google Calendar 이벤트 관리")
    subparsers = parser.add_subparsers(dest="command", help="명령어")

    # create 서브커맨드
    create_parser = subparsers.add_parser("create", help="일정 생성")
    create_parser.add_argument("--account", required=True, help="계정 이름")
    create_parser.add_argument("--summary", required=True, help="일정 제목")
    create_parser.add_argument("--start", required=True, help="시작 시간 (ISO 형식)")
    create_parser.add_argument("--end", required=True, help="종료 시간 (ISO 형식)")
    create_parser.add_argument("--description", help="일정 설명")
    create_parser.add_argument("--location", help="장소")
    create_parser.add_argument("--attendees", help="참석자 이메일 (쉼표 구분)")
    create_parser.add_argument("--timezone", default=DEFAULT_TIMEZONE, help=f"타임존 (기본: {DEFAULT_TIMEZONE})")
    create_parser.add_argument("--json", action="store_true", dest="json_output", help="JSON 형식 출력")

    # update 서브커맨드
    update_parser = subparsers.add_parser("update", help="일정 수정")
    update_parser.add_argument("--account", required=True, help="계정 이름")
    update_parser.add_argument("--event-id", required=True, help="이벤트 ID")
    update_parser.add_argument("--summary", help="일정 제목")
    update_parser.add_argument("--start", help="시작 시간 (ISO 형식)")
    update_parser.add_argument("--end", help="종료 시간 (ISO 형식)")
    update_parser.add_argument("--description", help="일정 설명")
    update_parser.add_argument("--location", help="장소")
    update_parser.add_argument("--attendees", help="참석자 이메일 (쉼표 구분)")
    update_parser.add_argument("--timezone", default=DEFAULT_TIMEZONE, help=f"타임존 (기본: {DEFAULT_TIMEZONE})")
    update_parser.add_argument("--json", action="store_true", dest="json_output", help="JSON 형식 출력")

    # delete 서브커맨드
    delete_parser = subparsers.add_parser("delete", help="일정 삭제")
    delete_parser.add_argument("--account", required=True, help="계정 이름")
    delete_parser.add_argument("--event-id", required=True, help="이벤트 ID")

    args = parser.parse_args()

    if not args.command:
        parser.error("명령어를 지정해주세요: create, update, delete")

    if args.command == "create":
        create_event(args)
    elif args.command == "update":
        update_event(args)
    elif args.command == "delete":
        delete_event(args)


def create_event(args):
    """일정을 생성한다."""
    try:
        service = get_calendar_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    attendees = None
    if args.attendees:
        attendees = [email.strip() for email in args.attendees.split(",")]

    event_body = build_event_body(
        summary=args.summary,
        start=args.start,
        end=args.end,
        timezone=args.timezone,
        description=args.description,
        location=args.location,
        attendees=attendees,
    )

    try:
        result = service.events().insert(calendarId="primary", body=event_body).execute()
    except Exception as e:
        print(f"❌ 일정 생성 실패: {e}", file=sys.stderr)
        sys.exit(1)

    if args.json_output:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        start_time, end_time = format_event_time(result)
        print(f"✅ 일정 생성 완료")
        print(f"   제목: {result.get('summary', '')}")
        print(f"   시간: {start_time} ~ {end_time}")
        if result.get("location"):
            print(f"   장소: {result['location']}")
        print(f"   Event ID: {result['id']}")
        print(f"   링크: {result.get('htmlLink', '')}")


def update_event(args):
    """일정을 수정한다."""
    try:
        service = get_calendar_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    # 기존 이벤트 조회
    try:
        existing = service.events().get(
            calendarId="primary",
            eventId=args.event_id,
        ).execute()
    except Exception as e:
        print(f"❌ 이벤트를 찾을 수 없습니다: {e}", file=sys.stderr)
        sys.exit(1)

    # 변경할 필드만 업데이트
    if args.summary:
        existing["summary"] = args.summary
    if args.description is not None:
        existing["description"] = args.description
    if args.location is not None:
        existing["location"] = args.location

    if args.start:
        start_iso, is_allday = parse_datetime(args.start, args.timezone)
        if is_allday:
            existing["start"] = {"date": start_iso}
        else:
            existing["start"] = {"dateTime": start_iso, "timeZone": args.timezone}

    if args.end:
        end_iso, is_allday = parse_datetime(args.end, args.timezone)
        if is_allday:
            existing["end"] = {"date": end_iso}
        else:
            existing["end"] = {"dateTime": end_iso, "timeZone": args.timezone}

    if args.attendees:
        existing["attendees"] = [
            {"email": email.strip()} for email in args.attendees.split(",")
        ]

    try:
        result = service.events().update(
            calendarId="primary",
            eventId=args.event_id,
            body=existing,
        ).execute()
    except Exception as e:
        print(f"❌ 일정 수정 실패: {e}", file=sys.stderr)
        sys.exit(1)

    if args.json_output:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        start_time, end_time = format_event_time(result)
        print(f"✅ 일정 수정 완료")
        print(f"   제목: {result.get('summary', '')}")
        print(f"   시간: {start_time} ~ {end_time}")
        print(f"   Event ID: {result['id']}")


def delete_event(args):
    """일정을 삭제한다."""
    try:
        service = get_calendar_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    # 삭제 전 이벤트 정보 확인
    try:
        event = service.events().get(
            calendarId="primary",
            eventId=args.event_id,
        ).execute()
        summary = event.get("summary", "(제목 없음)")
    except Exception as e:
        print(f"❌ 이벤트를 찾을 수 없습니다: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        service.events().delete(
            calendarId="primary",
            eventId=args.event_id,
        ).execute()
    except Exception as e:
        print(f"❌ 일정 삭제 실패: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"✅ 일정 삭제 완료")
    print(f"   제목: {summary}")
    print(f"   Event ID: {args.event_id}")


if __name__ == "__main__":
    main()
