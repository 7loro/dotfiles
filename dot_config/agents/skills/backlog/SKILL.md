---
name: backlog
description: >
  Nulab Backlog API 연동 스킬. Backlog 프로젝트 관리 도구의 REST API v2를 사용하여
  이슈, 프로젝트, Wiki, Git/PR, 알림, 사용자 관리 등 전체 기능을 수행한다.
  트리거: "backlog", "백로그", "이슈 조회", "이슈 생성", "이슈 목록",
  "프로젝트 목록", "Wiki 페이지", "PR 생성", "풀리퀘스트", "backlog API",
  "백로그 API", Backlog URL 언급 시.
---

# Backlog API

Nulab Backlog REST API v2 전체 기능을 지원하는 스킬.

## Configuration

환경변수에서 설정값을 읽는다. `~/.zsh_profile_work`에 정의되어 있다.

- `$BACKLOG_API_KEY` — API 키
- `$BACKLOG_SPACE_KEY` — 스페이스 식별자
- `$BACKLOG_DOMAIN` — 도메인 (예: backlog.com)
- `$BACKLOG_PROJECT_KEY` — 프로젝트 키

### 환경변수 로드 (필수)

**중요**: Bash 도구는 셸 상태가 명령 간 유지되지 않는다.
따라서 **모든 Bash curl 호출 시 반드시 환경변수를 먼저 로드**해야 한다.

모든 curl 명령 앞에 다음 prefix를 붙인다:

```bash
source ~/.zsh_profile_work 2>/dev/null;
```

예시:
```bash
source ~/.zsh_profile_work 2>/dev/null; curl -s "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/issues/PROJ-1?apiKey=${BACKLOG_API_KEY}"
```

**병렬 Bash 호출 시에도 각 호출마다 반드시 prefix를 붙여야 한다.**

### 환경변수 미설정 시

환경변수가 하나라도 비어있으면 **API 호출을 하지 않고** 아래 안내를 출력한다:

> 다음 환경변수가 설정되지 않았습니다. `~/.zsh_profile_work`에 추가해 주세요:
>
> | 환경변수 | 용도 |
> |----------|------|
> | `BACKLOG_API_KEY` | Backlog REST API 인증 키 |
> | `BACKLOG_SPACE_KEY` | Backlog 스페이스 식별자 (URL 앞부분) |
> | `BACKLOG_DOMAIN` | Backlog 도메인 (예: `backlog.com`) |
> | `BACKLOG_PROJECT_KEY` | 기본 프로젝트 키 (예: `CONTENTSHUB`) |
>
> ```bash
> # ~/.zsh_profile_work 에 추가
> export BACKLOG_API_KEY="your-api-key"
> export BACKLOG_SPACE_KEY="your-space"
> export BACKLOG_DOMAIN="backlog.com"
> export BACKLOG_PROJECT_KEY="YOUR_PROJECT"
> ```

인증 방식 상세: [references/auth.md](references/auth.md)

## API Reference Guide

요청에 해당하는 reference 파일을 읽어 API 스펙(method, path, parameters, response)을 확인한다.

| Category | File | Description |
|----------|------|-------------|
| Auth & Errors | [auth.md](references/auth.md) | 인증 방식, 에러 코드 |
| Space | [space.md](references/space.md) | 스페이스 정보, 활동, 디스크 사용량, 첨부파일 |
| User | [user.md](references/user.md) | 사용자 CRUD, 아이콘, 활동, 최근 조회 |
| Project | [project.md](references/project.md) | 프로젝트 CRUD, 멤버, 상태/이슈타입/카테고리/마일스톤/커스텀필드 설정 |
| Issue | [issue.md](references/issue.md) | 이슈 CRUD, 댓글, 첨부파일, 참여자, 공유파일 |
| Wiki | [wiki.md](references/wiki.md) | Wiki 페이지 CRUD, 첨부파일, 태그, 히스토리 |
| Document | [document.md](references/document.md) | 문서 CRUD, 트리, 첨부파일 |
| Git & PR | [git.md](references/git.md) | Git 저장소, PR CRUD, PR 댓글, PR 첨부파일 |
| File | [file.md](references/file.md) | 공유 파일 목록, 다운로드, 디스크 사용량 |
| Webhook | [webhook.md](references/webhook.md) | Webhook CRUD |
| Star | [star.md](references/star.md) | 스타 추가/삭제 |
| Notification | [notification.md](references/notification.md) | 알림 조회, 읽음 처리 |
| Watching | [watching.md](references/watching.md) | 워칭 CRUD, 읽음 처리 |
| Team | [team.md](references/team.md) | 팀 CRUD, 라이선스, 프로젝트 팀 |
| Rate Limit | [rate-limit.md](references/rate-limit.md) | API 호출 제한 확인 |

## Usage Examples

**모든 curl 호출 앞에 `source ~/.zsh_profile_work 2>/dev/null;` prefix를 반드시 붙인다.**

### curl로 이슈 목록 조회

```bash
source ~/.zsh_profile_work 2>/dev/null; curl -s "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/issues?apiKey=${BACKLOG_API_KEY}&projectId[]=12345&statusId[]=1&count=100"
```

### curl로 이슈 생성

```bash
source ~/.zsh_profile_work 2>/dev/null; curl -s -X POST "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/issues?apiKey=${BACKLOG_API_KEY}" \
  -d "projectId=12345&summary=새 이슈&issueTypeId=1&priorityId=3"
```

### curl로 이슈에 댓글 추가

```bash
source ~/.zsh_profile_work 2>/dev/null; curl -s -X POST "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/issues/PROJ-123/comments?apiKey=${BACKLOG_API_KEY}" \
  -d "content=작업 완료했습니다."
```

### 병렬 호출 예시 (각 Bash 호출마다 source 필수)

```bash
# 호출 1
source ~/.zsh_profile_work 2>/dev/null; curl -s "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/projects/${BACKLOG_PROJECT_KEY}/statuses?apiKey=${BACKLOG_API_KEY}"

# 호출 2 (별도 Bash 호출)
source ~/.zsh_profile_work 2>/dev/null; curl -s "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/projects/${BACKLOG_PROJECT_KEY}/users?apiKey=${BACKLOG_API_KEY}"
```

## Workflow

1. 사용자 요청에서 필요한 API 카테고리 파악
2. 해당 reference 파일을 읽어 엔드포인트 스펙 확인
3. API 호출 실행 (**반드시 source prefix 포함**):
   ```bash
   source ~/.zsh_profile_work 2>/dev/null; curl -s "https://${BACKLOG_SPACE_KEY}.${BACKLOG_DOMAIN}/api/v2/{path}?apiKey=${BACKLOG_API_KEY}"
   ```
4. 환경변수가 비어있으면 (source 후에도) 사용자에게 설정 안내 출력
5. 응답 파싱 후 결과 정리하여 사용자에게 전달

### 주의사항

- **모든 Bash 호출에 `source ~/.zsh_profile_work 2>/dev/null;` prefix 필수** (셸 상태 비유지)
- 환경변수는 `${VAR}` 형식으로 참조 (중괄호 포함)
- 병렬 Bash 호출 시 **각 호출마다** source prefix를 붙여야 함
