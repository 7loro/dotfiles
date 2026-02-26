"""Gmail 라벨 및 메시지 관리 스크립트.

사용법:
    uv run python scripts/manage_labels.py --account work list-labels
    uv run python scripts/manage_labels.py --account work create-label --name "프로젝트/A"
    uv run python scripts/manage_labels.py --account work mark-read --id <message_id>
    uv run python scripts/manage_labels.py --account work batch-mark-read --ids id1 id2 id3
    uv run python scripts/manage_labels.py --account work batch-mark-read --query "is:unread"
    uv run python scripts/manage_labels.py --account work star --id <message_id>
    uv run python scripts/manage_labels.py --account work archive --id <message_id>
    uv run python scripts/manage_labels.py --account work trash --id <message_id>
    uv run python scripts/manage_labels.py --account work modify --id <id> \
        --add-labels "Label_123,STARRED" --remove-labels "INBOX"
    uv run python scripts/manage_labels.py --account work list-drafts
    uv run python scripts/manage_labels.py --account work send-draft --draft-id <draft_id>
    uv run python scripts/manage_labels.py --account work profile
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from gmail_utils import get_gmail_service


def main():
    parser = argparse.ArgumentParser(description="Gmail 라벨/메시지 관리")
    parser.add_argument("--account", required=True, help="계정 이름")

    subparsers = parser.add_subparsers(dest="command", help="명령")

    # list-labels
    subparsers.add_parser("list-labels", help="라벨 목록")

    # create-label
    p_create = subparsers.add_parser("create-label", help="라벨 생성")
    p_create.add_argument("--name", required=True, help="라벨 이름")

    # mark-read
    p_read = subparsers.add_parser("mark-read", help="읽음 처리")
    p_read.add_argument("--id", required=True, help="메시지 ID")

    # batch-mark-read
    p_batch_read = subparsers.add_parser("batch-mark-read", help="여러 메시지 일괄 읽음 처리")
    p_batch_read.add_argument("--ids", nargs="+", help="메시지 ID 목록 (공백 구분)")
    p_batch_read.add_argument("--query", help="Gmail 검색 쿼리로 대상 선택 (예: is:unread)")
    p_batch_read.add_argument("--max", type=int, default=500, help="쿼리 사용 시 최대 처리 수 (기본: 500)")

    # star
    p_star = subparsers.add_parser("star", help="별표 추가")
    p_star.add_argument("--id", required=True, help="메시지 ID")

    # unstar
    p_unstar = subparsers.add_parser("unstar", help="별표 제거")
    p_unstar.add_argument("--id", required=True, help="메시지 ID")

    # archive
    p_archive = subparsers.add_parser("archive", help="보관 처리")
    p_archive.add_argument("--id", required=True, help="메시지 ID")

    # trash
    p_trash = subparsers.add_parser("trash", help="휴지통으로 이동")
    p_trash.add_argument("--id", required=True, help="메시지 ID")

    # untrash
    p_untrash = subparsers.add_parser("untrash", help="휴지통에서 복원")
    p_untrash.add_argument("--id", required=True, help="메시지 ID")

    # modify
    p_modify = subparsers.add_parser("modify", help="라벨 수정")
    p_modify.add_argument("--id", required=True, help="메시지 ID")
    p_modify.add_argument("--add-labels", default="", help="추가할 라벨 (쉼표 구분)")
    p_modify.add_argument("--remove-labels", default="", help="제거할 라벨 (쉼표 구분)")

    # list-drafts
    subparsers.add_parser("list-drafts", help="임시보관함 목록")

    # send-draft
    p_send_draft = subparsers.add_parser("send-draft", help="임시보관함 발송")
    p_send_draft.add_argument("--draft-id", required=True, help="Draft ID")

    # profile
    subparsers.add_parser("profile", help="프로필 정보")

    args = parser.parse_args()

    if not args.command:
        parser.error("명령을 지정해주세요.")

    try:
        service = get_gmail_service(args.account)
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        sys.exit(1)

    commands = {
        "list-labels": lambda: cmd_list_labels(service),
        "create-label": lambda: cmd_create_label(service, args.name),
        "mark-read": lambda: cmd_mark_read(service, args.id),
        "batch-mark-read": lambda: cmd_batch_mark_read(service, args.ids, args.query, args.max),
        "star": lambda: cmd_star(service, args.id),
        "unstar": lambda: cmd_unstar(service, args.id),
        "archive": lambda: cmd_archive(service, args.id),
        "trash": lambda: cmd_trash(service, args.id),
        "untrash": lambda: cmd_untrash(service, args.id),
        "modify": lambda: cmd_modify(service, args.id, args.add_labels, args.remove_labels),
        "list-drafts": lambda: cmd_list_drafts(service),
        "send-draft": lambda: cmd_send_draft(service, args.draft_id),
        "profile": lambda: cmd_profile(service),
    }

    try:
        commands[args.command]()
    except Exception as e:
        print(f"❌ 오류: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_list_labels(service):
    """라벨 목록을 표시한다."""
    result = service.users().labels().list(userId="me").execute()
    labels = result.get("labels", [])

    # 시스템 라벨과 사용자 라벨 분류
    system_labels = []
    user_labels = []
    for label in labels:
        if label.get("type") == "system":
            system_labels.append(label)
        else:
            user_labels.append(label)

    print("=== 시스템 라벨 ===")
    for label in sorted(system_labels, key=lambda x: x["name"]):
        print(f"  {label['name']} (ID: {label['id']})")

    if user_labels:
        print(f"\n=== 사용자 라벨 ({len(user_labels)}개) ===")
        for label in sorted(user_labels, key=lambda x: x["name"]):
            print(f"  {label['name']} (ID: {label['id']})")


def cmd_create_label(service, name: str):
    """새 라벨을 생성한다."""
    body = {
        "name": name,
        "labelListVisibility": "labelShow",
        "messageListVisibility": "show",
    }
    result = service.users().labels().create(userId="me", body=body).execute()
    print(f"✅ 라벨 생성됨: {result['name']} (ID: {result['id']})")


def cmd_mark_read(service, msg_id: str):
    """메시지를 읽음 처리한다."""
    service.users().messages().modify(
        userId="me",
        id=msg_id,
        body={"removeLabelIds": ["UNREAD"]},
    ).execute()
    print(f"✅ 읽음 처리: {msg_id}")


def cmd_batch_mark_read(service, ids: list[str] | None, query: str | None, max_results: int):
    """여러 메시지를 일괄 읽음 처리한다.

    --ids와 --query를 함께 사용하면 두 결과를 합쳐서 처리한다.
    batchModify는 최대 1,000건 제한이 있으므로 청크로 나눠 처리한다.
    """
    if not ids and not query:
        print("⚠️ --ids 또는 --query를 지정해주세요.")
        print("  예) --ids id1 id2 id3")
        print("  예) --query \"is:unread\"")
        return

    target_ids = list(ids) if ids else []

    if query:
        # 쿼리로 메시지 ID 수집 (페이지네이션 포함)
        params = {"userId": "me", "q": query, "maxResults": min(max_results, 500)}
        result = service.users().messages().list(**params).execute()
        target_ids.extend(m["id"] for m in result.get("messages", []))

        while "nextPageToken" in result and len(target_ids) < max_results:
            result = service.users().messages().list(
                **params, pageToken=result["nextPageToken"]
            ).execute()
            target_ids.extend(m["id"] for m in result.get("messages", []))

    # 중복 제거 (순서 유지)
    target_ids = list(dict.fromkeys(target_ids))

    if not target_ids:
        print("처리할 메시지가 없습니다.")
        return

    # 1,000건 단위로 청크 처리
    CHUNK = 1000
    total = len(target_ids)
    processed = 0

    for i in range(0, total, CHUNK):
        chunk = target_ids[i:i + CHUNK]
        service.users().messages().batchModify(
            userId="me",
            body={"ids": chunk, "removeLabelIds": ["UNREAD"]},
        ).execute()
        processed += len(chunk)

    print(f"✅ 읽음 처리 완료: {processed}건")


def cmd_star(service, msg_id: str):
    """메시지에 별표를 추가한다."""
    service.users().messages().modify(
        userId="me",
        id=msg_id,
        body={"addLabelIds": ["STARRED"]},
    ).execute()
    print(f"✅ 별표 추가: {msg_id}")


def cmd_unstar(service, msg_id: str):
    """메시지에서 별표를 제거한다."""
    service.users().messages().modify(
        userId="me",
        id=msg_id,
        body={"removeLabelIds": ["STARRED"]},
    ).execute()
    print(f"✅ 별표 제거: {msg_id}")


def cmd_archive(service, msg_id: str):
    """메시지를 보관 처리한다 (받은편지함에서 제거)."""
    service.users().messages().modify(
        userId="me",
        id=msg_id,
        body={"removeLabelIds": ["INBOX"]},
    ).execute()
    print(f"✅ 보관 처리: {msg_id}")


def cmd_trash(service, msg_id: str):
    """메시지를 휴지통으로 이동한다."""
    service.users().messages().trash(userId="me", id=msg_id).execute()
    print(f"✅ 휴지통 이동: {msg_id}")


def cmd_untrash(service, msg_id: str):
    """메시지를 휴지통에서 복원한다."""
    service.users().messages().untrash(userId="me", id=msg_id).execute()
    print(f"✅ 복원 완료: {msg_id}")


def cmd_modify(service, msg_id: str, add_labels: str, remove_labels: str):
    """메시지의 라벨을 수정한다."""
    body = {}
    if add_labels:
        body["addLabelIds"] = [l.strip() for l in add_labels.split(",")]
    if remove_labels:
        body["removeLabelIds"] = [l.strip() for l in remove_labels.split(",")]

    if not body:
        print("⚠️ --add-labels 또는 --remove-labels를 지정해주세요.")
        return

    service.users().messages().modify(userId="me", id=msg_id, body=body).execute()
    print(f"✅ 라벨 수정 완료: {msg_id}")
    if add_labels:
        print(f"   추가: {add_labels}")
    if remove_labels:
        print(f"   제거: {remove_labels}")


def cmd_list_drafts(service):
    """임시보관함 목록을 표시한다."""
    result = service.users().drafts().list(userId="me").execute()
    drafts = result.get("drafts", [])

    if not drafts:
        print("임시보관함이 비어있습니다.")
        return

    print(f"=== 임시보관함 ({len(drafts)}건) ===\n")
    for draft in drafts:
        msg = draft.get("message", {})
        # 상세 정보 조회
        detail = (
            service.users()
            .drafts()
            .get(userId="me", id=draft["id"], format="metadata", metadataHeaders=["To", "Subject"])
            .execute()
        )
        headers = detail.get("message", {}).get("payload", {}).get("headers", [])
        to_addr = next((h["value"] for h in headers if h["name"] == "To"), "")
        subject = next((h["value"] for h in headers if h["name"] == "Subject"), "(제목 없음)")

        print(f"  Draft ID: {draft['id']}")
        print(f"  수신: {to_addr}")
        print(f"  제목: {subject}")
        print()


def cmd_send_draft(service, draft_id: str):
    """임시보관함의 메일을 발송한다."""
    result = service.users().drafts().send(userId="me", body={"id": draft_id}).execute()
    print(f"✅ 임시보관 메일 발송 완료")
    print(f"   Message ID: {result.get('id', '')}")


def cmd_profile(service):
    """프로필 정보를 표시한다."""
    profile = service.users().getProfile(userId="me").execute()
    print("=== Gmail 프로필 ===")
    print(f"  이메일: {profile.get('emailAddress', '')}")
    print(f"  전체 메시지: {profile.get('messagesTotal', 0):,}건")
    print(f"  전체 스레드: {profile.get('threadsTotal', 0):,}건")
    print(f"  히스토리 ID: {profile.get('historyId', '')}")


if __name__ == "__main__":
    main()
