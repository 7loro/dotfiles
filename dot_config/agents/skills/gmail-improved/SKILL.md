---
name: gmail-improved
description: >
  Gmail API를 통해 다중 Google 계정의 이메일을 읽고, 검색하고, 보내고, 관리하는 스킬.
  트리거: "이메일 확인", "메일 읽어줘", "메일 보내줘", "이메일 검색",
  "check email", "send email", "reply to email", "search inbox" 등.
---

# Gmail

Gmail API를 통한 다중 계정 이메일 관리.

## 사전 확인

### 환경변수 확인

`GOOGLE_CLIENT_ID`와 `GOOGLE_CLIENT_SECRET`가 모두 설정되어 있는지 확인한다.
하나라도 비어있으면 **스크립트를 실행하지 않고** 아래 안내를 출력한다:

> 다음 환경변수가 설정되지 않았습니다. `~/.zsh_profile_work`에 추가해 주세요:
>
> | 환경변수 | 용도 |
> |----------|------|
> | `GOOGLE_CLIENT_ID` | Google OAuth 클라이언트 ID |
> | `GOOGLE_CLIENT_SECRET` | Google OAuth 클라이언트 시크릿 |
>
> ```bash
> # ~/.zsh_profile_work 에 추가
> export GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
> export GOOGLE_CLIENT_SECRET="GOCSPX-your-secret"
> ```

### 계정 확인

시작 전 `accounts.yaml` 파일 확인:
- 파일 없음 → [references/setup-guide.md](references/setup-guide.md) 안내
- 토큰 만료 → `uv run python scripts/setup_auth.py --account {name}` 재인증

## 메일 읽기/검색

```bash
# 최근 10개 메일
uv run python scripts/list_messages.py --account work --max 10

# 안 읽은 메일
uv run python scripts/list_messages.py --account work --query "is:unread"

# 특정 발신자
uv run python scripts/list_messages.py --account work --query "from:user@example.com"

# 메일 본문 읽기
uv run python scripts/read_message.py --account work --id <message_id>

# 스레드 전체 읽기
uv run python scripts/read_message.py --account work --thread <thread_id>
```

CLI 전체 옵션: [references/cli-usage.md](references/cli-usage.md)

## 메일 보내기 워크플로우

### Step 1: 맥락 수집

Explore SubAgent를 병렬로 실행하여 수신자 정보와 배경 수집.

### Step 2: 이전 대화 확인

수신자와의 기존 이메일 스레드 검색.

### Step 3: 초안 작성

메시지 작성 후 사용자 피드백 요청.

### Step 4: 테스트 발송

`[TEST]` 접두어를 붙여 본인에게 테스트 발송:
```bash
uv run python scripts/send_message.py --account work \
    --to "본인@email.com" \
    --subject "[TEST] 원래 제목" \
    --body "테스트 내용"
```

### Step 5: 실제 발송

사용자 확인 후 수신자에게 발송:
```bash
uv run python scripts/send_message.py --account work \
    --to "수신자@email.com" \
    --subject "제목" \
    --body "내용"
```

모든 발송 메일에 서명 추가: `Sent with Claude Code`

## 라벨/정리

```bash
# 라벨 목록
uv run python scripts/manage_labels.py --account work list-labels

# 읽음 처리
uv run python scripts/manage_labels.py --account work mark-read --id <id>

# 보관
uv run python scripts/manage_labels.py --account work archive --id <id>
```

## 에러 처리

| 상황 | 처리 |
|------|------|
| accounts.yaml 없음 | [setup-guide.md](references/setup-guide.md) 안내 |
| 토큰 만료 | `setup_auth.py --account {name}` 재인증 |
| credentials.json 없음 | Google Cloud Console에서 OAuth 클라이언트 ID 다운로드 안내 |

## 리소스

- `scripts/` - Gmail CLI 스크립트 (list_messages.py, read_message.py, send_message.py, manage_labels.py, setup_auth.py)
- `references/cli-usage.md` - CLI 전체 사용법
- `references/setup-guide.md` - 초기 설정 가이드
- `assets/accounts.default.yaml` - 계정 설정 템플릿
