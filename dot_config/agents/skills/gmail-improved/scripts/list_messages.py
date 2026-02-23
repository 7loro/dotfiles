"""Gmail 메일 목록 조회 스크립트.

사용법:
    uv run python scripts/list_messages.py --account work --max 10
    uv run python scripts/list_messages.py --account work --query "is:unread"
    uv run python scripts/list_messages.py --account work --query "from:user@example.com"
    uv run python scripts/list_messages.py --account work --labels INBOX,IMPORTANT
    uv run python scripts/list_messages.py --account work --full
    uv run python scripts/list_messages.py --account work --json
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from gmail_utils import decode_body, format_date, get_gmail_service, get_header


def main():
    parser = argparse.ArgumentParser(description="Gmail 메일 목록 조회")
    parser.add_argument("--account", required=True, help="계정 이름")
    parser.add_argument("--max", type=int, default=10, help="최대 조회 수 (기본: 10)")
    parser.add_argument("--query", default="", help="Gmail 검색 쿼리")
    parser.add_argument("--labels", default="", help="라벨 필터 (쉼표 구분)")
    parser.add_argument("--full", action="store_true", help="전체 내용 포함")
    parser.add_argument("--json", action="store_true", dest="json_output", help="JSON 형식 출력")
    args = parser.parse_args()

    try:
        service = get_gmail_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    # 메일 목록 조회
    list_params = {
        "userId": "me",
        "maxResults": args.max,
    }
    if args.query:
        list_params["q"] = args.query
    if args.labels:
        list_params["labelIds"] = [l.strip() for l in args.labels.split(",")]

    try:
        result = service.users().messages().list(**list_params).execute()
    except Exception as e:
        print(f"API 오류: {e}", file=sys.stderr)
        sys.exit(1)

    messages = result.get("messages", [])
    if not messages:
        print("메일이 없습니다.")
        return

    # 각 메일의 상세 정보 조회
    fmt = "full" if args.full else "metadata"
    metadata_headers = ["From", "To", "Subject", "Date"]

    results = []
    for msg_ref in messages:
        msg = (
            service.users()
            .messages()
            .get(
                userId="me",
                id=msg_ref["id"],
                format=fmt,
                metadataHeaders=metadata_headers if fmt == "metadata" else None,
            )
            .execute()
        )

        headers = msg.get("payload", {}).get("headers", [])
        entry = {
            "id": msg["id"],
            "threadId": msg["threadId"],
            "date": format_date(msg.get("internalDate", "0")),
            "from": get_header(headers, "From"),
            "to": get_header(headers, "To"),
            "subject": get_header(headers, "Subject"),
            "snippet": msg.get("snippet", ""),
            "labels": msg.get("labelIds", []),
            "isUnread": "UNREAD" in msg.get("labelIds", []),
        }

        if args.full:
            entry["body"] = decode_body(msg.get("payload", {}))

        results.append(entry)

    # 출력
    if args.json_output:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        print_messages(results, full=args.full)


def print_messages(messages: list[dict], full: bool = False):
    """메일 목록을 보기 좋게 출력한다."""
    total = len(messages)
    print(f"=== 메일 {total}건 ===\n")

    for i, msg in enumerate(messages, 1):
        unread = "📩" if msg["isUnread"] else "📧"
        print(f"{unread} [{i}/{total}] {msg['subject']}")
        print(f"   발신: {msg['from']}")
        print(f"   날짜: {msg['date']}")
        print(f"   ID: {msg['id']}  Thread: {msg['threadId']}")

        if full and msg.get("body"):
            print(f"   ---본문---")
            # 본문 최대 500자 표시
            body = msg["body"].strip()
            if len(body) > 500:
                body = body[:500] + "... (생략)"
            for line in body.split("\n"):
                print(f"   {line}")
        else:
            print(f"   미리보기: {msg['snippet'][:100]}")

        if i < total:
            print()


if __name__ == "__main__":
    main()
