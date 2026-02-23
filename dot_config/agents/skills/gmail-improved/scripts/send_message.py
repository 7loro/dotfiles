"""Gmail 메일 발송 스크립트.

사용법:
    uv run python scripts/send_message.py --account work \
        --to "user@example.com" --subject "제목" --body "내용"

    uv run python scripts/send_message.py --account work \
        --to "user@example.com" --subject "공지" --body "<h1>제목</h1>" --html

    uv run python scripts/send_message.py --account work \
        --to "user@example.com" --subject "파일" --body "첨부 확인" \
        --attach file1.pdf,file2.xlsx

    uv run python scripts/send_message.py --account work \
        --to "user@example.com" --subject "Re: 원래제목" --body "답장" \
        --reply-to <message_id> --thread <thread_id>

    uv run python scripts/send_message.py --account work \
        --to "user@example.com" --subject "초안" --body "내용" --draft
"""

import argparse
import base64
import mimetypes
import sys
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email import encoders
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from gmail_utils import get_account_email, get_gmail_service, get_header

# 발송 메일에 추가하는 서명
SIGNATURE = "\n\n---\nSent with Claude Code"


def main():
    parser = argparse.ArgumentParser(description="Gmail 메일 발송")
    parser.add_argument("--account", required=True, help="계정 이름")
    parser.add_argument("--to", required=True, help="수신자 이메일")
    parser.add_argument("--subject", required=True, help="메일 제목")
    parser.add_argument("--body", required=True, help="메일 본문")
    parser.add_argument("--html", action="store_true", help="HTML 형식으로 발송")
    parser.add_argument("--attach", default="", help="첨부파일 경로 (쉼표 구분)")
    parser.add_argument("--reply-to", dest="reply_to", help="답장 대상 메시지 ID")
    parser.add_argument("--thread", help="스레드 ID")
    parser.add_argument("--draft", action="store_true", help="임시보관함에 저장")
    parser.add_argument("--cc", default="", help="참조 (쉼표 구분)")
    parser.add_argument("--bcc", default="", help="숨은 참조 (쉼표 구분)")
    args = parser.parse_args()

    try:
        service = get_gmail_service(args.account)
        sender_email = get_account_email(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    # 답장 시 원본 메시지의 Message-ID, References 헤더 조회
    in_reply_to = None
    references = None
    if args.reply_to:
        try:
            orig_msg = (
                service.users()
                .messages()
                .get(userId="me", id=args.reply_to, format="metadata", metadataHeaders=["Message-ID", "References"])
                .execute()
            )
            orig_headers = orig_msg.get("payload", {}).get("headers", [])
            in_reply_to = get_header(orig_headers, "Message-ID")
            references = get_header(orig_headers, "References")
            if in_reply_to and references:
                references = f"{references} {in_reply_to}"
            elif in_reply_to:
                references = in_reply_to
        except Exception:
            pass  # 원본 헤더 조회 실패 시 무시

    # MIME 메시지 생성
    attachments = [f.strip() for f in args.attach.split(",") if f.strip()] if args.attach else []

    if attachments:
        message = MIMEMultipart()
        body_with_sig = args.body + SIGNATURE
        if args.html:
            sig_html = SIGNATURE.replace("\n", "<br>")
            body_with_sig = args.body + sig_html
            message.attach(MIMEText(body_with_sig, "html"))
        else:
            message.attach(MIMEText(body_with_sig, "plain"))

        # 첨부파일 추가
        for filepath in attachments:
            path = Path(filepath)
            if not path.exists():
                print(f"⚠️ 첨부파일 없음: {filepath}", file=sys.stderr)
                continue

            content_type, _ = mimetypes.guess_type(str(path))
            if content_type is None:
                content_type = "application/octet-stream"
            main_type, sub_type = content_type.split("/", 1)

            with open(path, "rb") as f:
                attachment = MIMEBase(main_type, sub_type)
                attachment.set_payload(f.read())
            encoders.encode_base64(attachment)
            attachment.add_header("Content-Disposition", "attachment", filename=path.name)
            message.attach(attachment)
    else:
        body_with_sig = args.body + SIGNATURE
        if args.html:
            sig_html = SIGNATURE.replace("\n", "<br>")
            body_with_sig = args.body + sig_html
            message = MIMEText(body_with_sig, "html")
        else:
            message = MIMEText(body_with_sig, "plain")

    message["to"] = args.to
    message["from"] = sender_email
    message["subject"] = args.subject

    if args.cc:
        message["cc"] = args.cc
    if args.bcc:
        message["bcc"] = args.bcc
    if in_reply_to:
        message["In-Reply-To"] = in_reply_to
    if references:
        message["References"] = references

    # base64 인코딩
    raw = base64.urlsafe_b64encode(message.as_bytes()).decode()

    # 발송 또는 임시보관
    try:
        if args.draft:
            body = {"message": {"raw": raw}}
            if args.thread:
                body["message"]["threadId"] = args.thread
            result = service.users().drafts().create(userId="me", body=body).execute()
            print(f"✅ 임시보관함에 저장됨")
            print(f"   Draft ID: {result['id']}")
        else:
            body = {"raw": raw}
            if args.thread:
                body["threadId"] = args.thread
            result = service.users().messages().send(userId="me", body=body).execute()
            print(f"✅ 메일 발송 완료")
            print(f"   수신: {args.to}")
            print(f"   제목: {args.subject}")
            print(f"   Message ID: {result['id']}")
            if args.thread:
                print(f"   Thread ID: {args.thread}")
    except Exception as e:
        print(f"❌ 발송 실패: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
