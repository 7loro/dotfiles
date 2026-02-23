# Gmail CLI 상세 사용법

## 메일 목록 조회

```bash
# 최근 10개
uv run python scripts/list_messages.py --account work --max 10

# 안 읽은 메일
uv run python scripts/list_messages.py --account work --query "is:unread"

# 특정 발신자
uv run python scripts/list_messages.py --account work --query "from:user@example.com"

# 날짜 범위
uv run python scripts/list_messages.py --account work --query "after:2024/01/01 before:2024/12/31"

# 라벨 필터
uv run python scripts/list_messages.py --account work --labels INBOX,IMPORTANT

# 전체 내용 포함
uv run python scripts/list_messages.py --account work --full

# JSON 출력
uv run python scripts/list_messages.py --account work --json
```

## 메일 읽기

```bash
# 메일 읽기
uv run python scripts/read_message.py --account work --id <message_id>

# 스레드 전체 읽기
uv run python scripts/read_message.py --account work --thread <thread_id>

# 첨부파일 저장
uv run python scripts/read_message.py --account work --id <message_id> --save-attachments ./downloads
```

## 메일 발송

```bash
# 새 메일
uv run python scripts/send_message.py --account work \
    --to "user@example.com" \
    --subject "제목" \
    --body "내용"

# HTML 메일
uv run python scripts/send_message.py --account work \
    --to "user@example.com" \
    --subject "공지사항" \
    --body "<h1>제목</h1><p>내용</p>" \
    --html

# 첨부파일 포함
uv run python scripts/send_message.py --account work \
    --to "user@example.com" \
    --subject "파일 전달" \
    --body "첨부파일 확인 부탁드립니다." \
    --attach file1.pdf,file2.xlsx

# 답장
uv run python scripts/send_message.py --account work \
    --to "user@example.com" \
    --subject "Re: 원래 제목" \
    --body "답장 내용" \
    --reply-to <message_id> \
    --thread <thread_id>

# 임시보관함에 저장
uv run python scripts/send_message.py --account work \
    --to "user@example.com" \
    --subject "나중에 보낼 메일" \
    --body "초안 내용" \
    --draft
```

## 라벨/메시지 관리

```bash
# 라벨 목록
uv run python scripts/manage_labels.py --account work list-labels

# 라벨 생성
uv run python scripts/manage_labels.py --account work create-label --name "프로젝트/A"

# 읽음 처리
uv run python scripts/manage_labels.py --account work mark-read --id <message_id>

# 별표/해제
uv run python scripts/manage_labels.py --account work star --id <message_id>
uv run python scripts/manage_labels.py --account work unstar --id <message_id>

# 보관
uv run python scripts/manage_labels.py --account work archive --id <message_id>

# 휴지통/복원
uv run python scripts/manage_labels.py --account work trash --id <message_id>
uv run python scripts/manage_labels.py --account work untrash --id <message_id>

# 라벨 추가/제거
uv run python scripts/manage_labels.py --account work modify --id <message_id> \
    --add-labels "Label_123,STARRED" --remove-labels "INBOX"

# 임시보관함 목록
uv run python scripts/manage_labels.py --account work list-drafts

# 임시보관함 발송
uv run python scripts/manage_labels.py --account work send-draft --draft-id <draft_id>

# 프로필 확인
uv run python scripts/manage_labels.py --account work profile
```
