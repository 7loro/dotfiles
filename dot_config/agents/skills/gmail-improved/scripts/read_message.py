"""Gmail 메일 본문 읽기 스크립트.

사용법:
    uv run python scripts/read_message.py --account work --id <message_id>
    uv run python scripts/read_message.py --account work --thread <thread_id>
    uv run python scripts/read_message.py --account work --id <id> --save-attachments ./downloads
"""

import argparse
import base64
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from gmail_utils import decode_body, format_date, get_gmail_service, get_header


def main():
    parser = argparse.ArgumentParser(description="Gmail 메일 읽기")
    parser.add_argument("--account", required=True, help="계정 이름")
    parser.add_argument("--id", dest="msg_id", help="메시지 ID")
    parser.add_argument("--thread", dest="thread_id", help="스레드 ID (전체 대화 읽기)")
    parser.add_argument("--save-attachments", dest="save_dir", help="첨부파일 저장 디렉토리")
    args = parser.parse_args()

    if not args.msg_id and not args.thread_id:
        parser.error("--id 또는 --thread를 지정해주세요.")

    try:
        service = get_gmail_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    if args.thread_id:
        read_thread(service, args.thread_id, args.save_dir)
    else:
        read_message(service, args.msg_id, args.save_dir)


def read_message(service, msg_id: str, save_dir: str | None = None):
    """단일 메시지를 읽고 출력한다."""
    try:
        msg = service.users().messages().get(userId="me", id=msg_id, format="full").execute()
    except Exception as e:
        print(f"API 오류: {e}", file=sys.stderr)
        sys.exit(1)

    print_message_detail(msg)

    # 첨부파일 처리
    attachments = get_attachments(msg)
    if attachments:
        print(f"\n📎 첨부파일 ({len(attachments)}개):")
        for att in attachments:
            print(f"   - {att['filename']} ({att['mimeType']}, {att['size']} bytes)")

        if save_dir:
            save_attachments(service, msg_id, attachments, save_dir)


def read_thread(service, thread_id: str, save_dir: str | None = None):
    """스레드 전체를 읽고 출력한다."""
    try:
        thread = service.users().threads().get(userId="me", id=thread_id, format="full").execute()
    except Exception as e:
        print(f"API 오류: {e}", file=sys.stderr)
        sys.exit(1)

    messages = thread.get("messages", [])
    print(f"=== 스레드 ({len(messages)}건) ===\n")

    for i, msg in enumerate(messages, 1):
        print(f"--- 메시지 {i}/{len(messages)} ---")
        print_message_detail(msg)

        attachments = get_attachments(msg)
        if attachments:
            print(f"\n📎 첨부파일 ({len(attachments)}개):")
            for att in attachments:
                print(f"   - {att['filename']} ({att['mimeType']})")

            if save_dir:
                save_attachments(service, msg["id"], attachments, save_dir)

        print()


def print_message_detail(msg: dict):
    """메시지 상세 정보를 출력한다."""
    headers = msg.get("payload", {}).get("headers", [])

    subject = get_header(headers, "Subject")
    from_addr = get_header(headers, "From")
    to_addr = get_header(headers, "To")
    cc_addr = get_header(headers, "Cc")
    date = format_date(msg.get("internalDate", "0"))

    print(f"제목: {subject}")
    print(f"발신: {from_addr}")
    print(f"수신: {to_addr}")
    if cc_addr:
        print(f"참조: {cc_addr}")
    print(f"날짜: {date}")
    print(f"ID: {msg['id']}")
    print(f"라벨: {', '.join(msg.get('labelIds', []))}")
    print()

    body = decode_body(msg.get("payload", {}))
    if body:
        print("--- 본문 ---")
        print(body.strip())
    else:
        print("(본문 없음)")


def get_attachments(msg: dict) -> list[dict]:
    """메시지에서 첨부파일 정보를 추출한다."""
    attachments = []
    payload = msg.get("payload", {})

    def _scan_parts(parts):
        for part in parts:
            filename = part.get("filename", "")
            if filename and part.get("body", {}).get("attachmentId"):
                attachments.append({
                    "filename": filename,
                    "mimeType": part.get("mimeType", ""),
                    "size": part.get("body", {}).get("size", 0),
                    "attachmentId": part["body"]["attachmentId"],
                })
            if part.get("parts"):
                _scan_parts(part["parts"])

    if payload.get("parts"):
        _scan_parts(payload["parts"])

    return attachments


def save_attachments(service, msg_id: str, attachments: list[dict], save_dir: str):
    """첨부파일을 디스크에 저장한다."""
    save_path = Path(save_dir)
    save_path.mkdir(parents=True, exist_ok=True)

    for att in attachments:
        try:
            attachment = (
                service.users()
                .messages()
                .attachments()
                .get(userId="me", messageId=msg_id, id=att["attachmentId"])
                .execute()
            )
            data = base64.urlsafe_b64decode(attachment["data"])
            filepath = save_path / att["filename"]
            with open(filepath, "wb") as f:
                f.write(data)
            print(f"   ✅ 저장됨: {filepath}")
        except Exception as e:
            print(f"   ❌ 저장 실패 ({att['filename']}): {e}")


if __name__ == "__main__":
    main()
