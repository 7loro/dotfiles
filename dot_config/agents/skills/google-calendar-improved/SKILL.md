---
name: google-calendar-improved
description: >
  Google Calendar API를 통해 다중 계정의 일정을 조회, 생성, 수정, 삭제하는 스킬.
  병렬 SubAgent로 여러 계정 동시 조회, 충돌 감지, 시간대 자동 처리 지원.
  트리거: "일정 확인", "캘린더", "오늘 일정", "이번 주 일정", "일정 잡아줘",
  "미팅 만들어줘", "일정 변경", "일정 삭제", "스케줄" 등.
---

# Google Calendar

Google Calendar API를 통한 다중 계정 일정 관리.

## 사전 확인

### 환경변수 확인

`CLAUDE_SKILL_GOOGLE_CLIENT_ID`와 `CLAUDE_SKILL_GOOGLE_CLIENT_SECRET`가 모두 설정되어 있는지 확인한다.
하나라도 비어있으면 **스크립트를 실행하지 않고** 아래 안내를 출력한다:

> 다음 환경변수가 설정되지 않았습니다. `~/.zsh_profile_work`에 추가해 주세요:
>
> | 환경변수 | 용도 |
> |----------|------|
> | `CLAUDE_SKILL_GOOGLE_CLIENT_ID` | Google OAuth 클라이언트 ID |
> | `CLAUDE_SKILL_GOOGLE_CLIENT_SECRET` | Google OAuth 클라이언트 시크릿 |
>
> ```bash
> # ~/.zsh_profile_work 에 추가
> export CLAUDE_SKILL_GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
> export CLAUDE_SKILL_GOOGLE_CLIENT_SECRET="GOCSPX-your-secret"
> ```

### 계정 확인

시작 전 `accounts/` 폴더 확인:
- 폴더 비어있음 → [references/setup-guide.md](references/setup-guide.md) 안내
- 토큰 만료 → `uv run python scripts/setup_auth.py --account {name}` 재인증

## 일정 조회

### 단일 계정

```bash
uv run python scripts/fetch_events.py --account work --days 7
```

### 다중 계정 (병렬 SubAgent)

각 계정별로 Task 도구를 **병렬** 호출:

```python
# 병렬 실행 - 단일 메시지에 여러 Task 호출
Task(subagent_type="general-purpose", prompt="fetch calendar for work account")
Task(subagent_type="general-purpose", prompt="fetch calendar for personal account")
```

각 SubAgent 실행:
```bash
uv run python scripts/fetch_events.py --account {account_name} --days 7
```

### 결과 통합

- 모든 계정 이벤트를 시간순 정렬
- 동일 시간대 이벤트 = 충돌로 표시
- 계정별 색상/아이콘 구분

## 출력 형식

```
📅 2026-01-06 (월) 일정

[09:00-10:00] 🔵 팀 스탠드업 (work)
[10:00-11:30] 🟢 치과 예약 (personal)
[14:00-15:00] 🔵 고객 미팅 - 삼양 (work)
              ⚠️ 충돌: 개인 일정과 겹침
[14:00-14:30] 🟢 은행 방문 (personal)

📊 오늘 총 4개 일정 (work: 2, personal: 2)
   ⚠️ 1건 충돌
```

## 일정 생성

```bash
# 시간 지정 일정
uv run python scripts/manage_events.py create \
    --summary "팀 미팅" \
    --start "2026-01-06T14:00:00" \
    --end "2026-01-06T15:00:00" \
    --account work

# 종일 일정
uv run python scripts/manage_events.py create \
    --summary "연차" \
    --start "2026-01-10" \
    --end "2026-01-11" \
    --account personal
```

## 일정 수정

```bash
uv run python scripts/manage_events.py update \
    --event-id "abc123" \
    --summary "팀 미팅 (변경)" \
    --start "2026-01-06T14:21:00" \
    --account work
```

## 일정 삭제

```bash
uv run python scripts/manage_events.py delete \
    --event-id "abc123" \
    --account work
```

## CLI 옵션

| 옵션 | 설명 |
|------|------|
| `--summary` | 일정 제목 |
| `--start` | 시작 시간 (ISO: 2026-01-06T14:00:00 또는 2026-01-06) |
| `--end` | 종료 시간 |
| `--description` | 일정 설명 |
| `--location` | 장소 |
| `--attendees` | 참석자 이메일 (쉼표 구분) |
| `--account` | 계정명 |
| `--timezone` | 타임존 (기본: Asia/Seoul) |
| `--json` | JSON 출력 |

## 에러 처리

| 상황 | 처리 |
|------|------|
| accounts/ 비어있음 | [setup-guide.md](references/setup-guide.md) 안내 |
| 토큰 만료 | 해당 계정 재인증, 나머지 정상 조회 |
| API 할당량 초과 | 잠시 후 재시도 안내 |
| 네트워크 오류 | 연결 확인 요청 |

## 리소스

- `scripts/setup_auth.py` - 계정별 OAuth 인증 및 토큰 저장
- `scripts/fetch_events.py` - 이벤트 조회 CLI
- `scripts/manage_events.py` - 이벤트 생성/수정/삭제 CLI
- `scripts/calendar_client.py` - Google Calendar API 클라이언트
- `references/setup-guide.md` - 초기 설정 가이드

## 보안 주의사항

- `accounts/*.json`: refresh token 포함, 커밋 금지
- `references/credentials.json`: Client Secret 포함, 커밋 금지
