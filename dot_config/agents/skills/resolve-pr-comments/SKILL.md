---
name: resolve-pr-comments
description: |
  PR 리뷰 코멘트를 확인하고 반영 여부를 판단하여 코드를 수정한 뒤, 커밋·푸시하고 각 코멘트에 처리 결과를 답글로 다는 스킬.
  "PR 리뷰 반영해줘", "리뷰 코멘트 처리", "review 반영", "리뷰 반영하고 답글 달아줘", "코멘트 반영해줘" 등의 요청 시 반드시 사용한다.
  PR 번호를 인자로 받거나 생략하면 현재 브랜치의 PR을 자동 감지한다.
argument-hint: "[PR번호 또는 URL]"
---

# Resolve PR Comments

PR 리뷰 코멘트를 체계적으로 처리하는 워크플로우.
코멘트 수집 → 분류 → 사용자 확인 → 코드 수정 → 커밋/푸시 → 답글 순으로 진행한다.

---

## 실행 방식 (Subagent 위임)

⚠️ **이 스킬은 토큰 절약을 위해 subagent에 작업을 위임하여 실행한다.** PR 코멘트·코드·diff 등 대량 컨텍스트를 부모 세션에 누적시키지 않기 위함이다.

### 부모 세션 역할
- 사용자와의 상호작용 (AskUserQuestion — Phase 2 분류 확인)
- Subagent 호출·결과 중계
- 최종 완료 보고

### Subagent 위임 흐름

| 단계 | 담당 | 작업 |
|------|------|------|
| **Phase 1** | Subagent A (general-purpose) | PR 식별 + 코멘트 수집 + 분류 → 분류 테이블만 리턴 |
| **Phase 2** | 부모 | 분류 결과에 대한 사용자 확인 (AskUserQuestion) |
| **Phase 3~5** | Subagent B (general-purpose) | 코드 수정 + 커밋·푸시 + 답글 작성 → 완료 요약만 리턴 |

### 위임 프롬프트 템플릿

**Subagent A 프롬프트** (Phase 1):
```
PR #{번호}의 리뷰 코멘트를 수집하고 분류해줘.

컨텍스트:
- 작업 디렉토리: {cwd}
- PR 번호 또는 URL: {인자}
- 현재 브랜치: {branch}

아래 SKILL.md의 Phase 1 전체 절차를 따라 수행해:
~/.config/agents/skills/resolve-pr-comments/SKILL.md

결과로 아래 분류 테이블만 리턴해 (본문·전체 스레드 내용 생략):

| # | comment_id | 분류 | 파일:라인 | 코멘트 요약 | 대응 방안 |

처리 대상이 없으면 "새로운 리뷰 코멘트 없음"으로 리턴.
```

**Subagent B 프롬프트** (Phase 3~5):
```
PR #{번호}의 리뷰 코멘트 중 아래 "반영" 분류된 항목들을 처리해줘.

반영 대상:
{Phase 2에서 사용자 확인 완료된 분류 결과 JSON/테이블}

작업:
1. Phase 3: 각 반영 항목에 대해 코드 수정
2. Phase 4: 단일 커밋으로 묶어 `review:` 타입 커밋 + 푸시
3. Phase 5: 각 스레드 root에 답글 전송 (처리 결과 요약)

SKILL.md Phase 3~5 절차 준수:
~/.config/agents/skills/resolve-pr-comments/SKILL.md

결과로 아래만 리턴:
- 커밋 SHA
- 수정 파일 수
- 답글 전송 성공 수
- 실패가 있으면 해당 내역
```

**주의**: Subagent는 부모 대화 맥락을 모른다. PR 번호, 분류 결과 등 필요한 정보를 명시적으로 전달한다.

---

## Phase 1: PR 및 코멘트 수집

### 1-1. PR 식별

인자로 PR 번호나 URL이 있으면 해당 PR을 사용한다. 없으면 현재 브랜치에서 자동 감지:

```bash
gh pr view --json number,url,headRefName,author
```

PR을 찾을 수 없으면 사용자에게 PR 번호를 요청하고 중단한다.

### 1-2. 브랜치 확인

현재 로컬 브랜치가 PR의 `headRefName`과 일치하는지 확인한다.
불일치하면 사용자에게 경고하고 계속할지 확인한다 — 잘못된 브랜치에서 수정하면 push가 PR에 반영되지 않는다.

### 1-3. 리포지토리 정보

```bash
gh repo view --json owner,name -q '"\(.owner.login)/\(.name)"'
```

`{owner}`와 `{repo}` 변수를 이후 API 호출에 사용한다.

### 1-4. 리뷰 코멘트 수집

인라인 리뷰 코멘트(코드 라인에 달린 코멘트)를 수집:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
```

응답에서 활용할 주요 필드:
- `id` — 코멘트 ID (답글 전송 시 사용)
- `body` — 코멘트 본문
- `path` — 대상 파일 경로
- `line` / `start_line` — 대상 라인 범위
- `user.login` — 작성자
- `in_reply_to_id` — 답글 대상 ID (null이면 스레드 시작점)
- `created_at` — 작성 시각

### 1-5. 스레드 그룹화

`in_reply_to_id` 기준으로 코멘트를 스레드별로 그룹화한다:
- `in_reply_to_id == null` → 스레드 시작 코멘트 (root)
- `in_reply_to_id != null` → 해당 root에 대한 후속 대화

### 1-6. 필터링

**처리 대상에서 제외:**
- PR 작성자 본인만의 코멘트 스레드 (자기 메모)

**제외하되 재포함하는 경우:**
- PR 작성자가 이미 답글을 단 스레드는 기본 제외 — **단, 그 답글 이후에 리뷰어가 추가 코멘트를 남겼으면 재포함**

필터링 후 처리 대상 코멘트가 없으면 "새로운 리뷰 코멘트가 없습니다"로 **조기 종료**한다.

---

## Phase 2: 코멘트 분류

### 분류 카테고리

| 분류 | 기준 | 예시 |
|------|------|------|
| **반영** | 코드 수정이 필요한 명확한 피드백 | 네이밍 변경, null 체크, 로직 수정, suggestion 블록 |
| **미반영** | 수정 불필요 또는 의도된 설계 | 이미 반영됨, 설계 의도, 스타일 차이 |
| **논의 필요** | 사용자 판단이 필요 | 큰 구조 변경, 트레이드오프 있는 제안 |

### 분류 원칙

- 단순 수정(네이밍, 오타, 포맷)은 → **반영**
- GitHub suggestion 블록(` ```suggestion `)이 있으면 → **반영** (제안된 코드를 그대로 적용)
- 기능 변경이나 구조적 리팩토링 → **논의 필요**
- 확신이 없으면 → **논의 필요** (잘못된 자동 반영보다 사용자 확인이 안전하다)
- 분류 전에 대상 코드와 스레드 맥락을 충분히 파악한다

### 사용자 확인 (필수 체크포인트)

분류 결과를 테이블로 제시하고 **반드시 사용자 확인**을 받는다:

```
## PR #{number} 리뷰 코멘트 분류 결과

| # | 분류 | 파일 | 코멘트 요약 | 대응 방안 |
|---|------|------|------------|-----------|
| 1 | ✅ 반영 | `lib/feature/foo.dart:42` | 변수명 camelCase | `foobar` → `fooBar` |
| 2 | ⏭️ 미반영 | `lib/core/bar.dart:15` | null 체크 추가 | 상위에서 이미 검증됨 |
| 3 | 💬 논의 | `lib/shared/baz.dart:88` | 함수 분리 제안 | 구조 변경 범위가 큼 |

이 분류가 맞는지 확인해 주세요. 조정이 필요하면 말씀해 주세요.
```

사용자가 분류를 조정하면 반영한다.
사용자 확인 없이 Phase 3으로 넘어가지 않는다.

---

## Phase 3: 코드 수정

**반영** 분류된 코멘트에 대해서만 코드를 수정한다.

### 수정 원칙

- 코멘트가 요청한 범위만 수정한다 — 주변 코드 "개선" 금지
- 수정 전 반드시 대상 파일을 읽고 현재 상태를 확인한다
- GitHub suggestion이 있으면 해당 코드를 정확히 적용한다
- 프로젝트의 `.claude/rules/` 코딩 컨벤션을 준수한다
- `build_runner` 재생성이 필요한 변경(freezed, riverpod 등)이면 수정 후 실행한다

### 수정 내역 기록

각 코멘트별 수정 내역을 메모해 둔다 (Phase 5 답글 작성에 사용):

```
코멘트 #{comment_id} ({path}:{line}):
  - `foobar` → `fooBar` 변수명 변경
```

---

## Phase 4: 커밋 및 푸시

모든 수정이 완료된 후 **한 번에** 커밋하고 푸시한다.

### 커밋 메시지

- **타입**: `review:`
- **기본 형식**: `review: PR 리뷰 코멘트 반영`
- 기존에 `review:` 커밋이 있으면 차수를 올린다: `review: PR 2차 리뷰 코멘트 반영`
- 중간 커밋 금지 — 모든 수정을 단일 커밋으로 만든다

### 차수 판별

```bash
git log --oneline | grep -c "^.\{7\} review:"
```

기존 review 커밋 수에 따라 차수를 결정한다.

### 푸시

```bash
git push
```

push 실패 시(remote가 앞서 있는 경우) 사용자에게 알리고 판단을 위임한다.
`--force` 등의 위험한 옵션을 자동으로 사용하지 않는다.

---

## Phase 5: 코멘트 답글

각 코멘트 스레드에 처리 결과를 답글로 작성한다.

### 답글 형식

**반영한 경우:**
```
반영했습니다.
- `{path}`: {구체적 수정 내역}
```

**미반영인 경우:**
```
아래 사유로 현재 코드를 유지합니다.
- {사유}
```

- 간결하게 작성한다. 인사말, 감사 표현 등 불필요한 수식어를 넣지 않는다.
- 한 스레드에 여러 지적이 있으면 답글 하나에 모두 포함한다.

### 답글 전송 방법

각 스레드의 **root 코멘트 ID**에 대해 답글을 보낸다.
답글 본문에 특수문자·줄바꿈·backtick 이 포함될 수 있으므로, heredoc 을 변수로 캡처한 뒤 `jq --arg` 로 안전하게 JSON 인코딩한다.

> ⚠️ **임시 파일 + `cat >` 패턴 금지**
> `mktemp` 는 이미 파일을 생성하므로 zsh 기본 `noclobber` 옵션과 결합하면 `cat > "$FILE"` 가 `file exists` 에러로 막혀 빈 body 가 전송된다. 또한 macOS(BSD) `mktemp` 는 template 이 `X` 로 끝나야 해서 `pr_reply_XXXXXX.txt` 같이 suffix 가 붙으면 치환이 일어나지 않는다. 두 함정을 동시에 피하려면 애초에 **파일을 쓰지 않는 게 정답**이다.

```bash
# 1. 답글 본문을 변수에 캡처 (임시 파일 불필요)
#    heredoc 을 'EOF' 로 quote 하면 내부 $ · backtick · backslash 도 안전
BODY=$(cat << 'REPLY_EOF'
반영했습니다.
- `lib/feature/foo.dart:42`: `foobar` → `fooBar` 변수명 변경
REPLY_EOF
)

# 2. JSON 변환 후 API 전송 — jq --arg 가 quote/escape 를 처리
jq -n --arg body "$BODY" '{"body": $body}' \
  | gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
    --method POST --input -
```

- 여러 답글을 보낼 때는 각 답글마다 `BODY=$(cat << 'REPLY_EOF' ... REPLY_EOF)` 블록을 새로 쓴다 (변수 덮어쓰기 OK)
- 답글이 성공했는지는 응답 JSON 의 `.id` 존재 여부로 확인 (`.message` 가 있으면 실패)

### 완료 보고

모든 답글 작성 후 결과를 요약 보고한다:

```
## PR #{number} 리뷰 코멘트 처리 완료

- ✅ 반영: N건 (커밋: `{short_sha}`)
- ⏭️ 미반영: N건
- 💬 논의: N건

각 코멘트에 답글을 작성했습니다.
```
