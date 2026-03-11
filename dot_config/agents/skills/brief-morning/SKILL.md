---
name: brief-morning
description: |
  아침 업무 시작 루틴: 어제 작업 요약 및 PR 리뷰 목록 확인.
  트리거: "아침 브리핑", "모닝 브리핑", "morning brief", "업무 시작", "/brief-morning" 등.
  config.yaml이 없으면 사용자에게 설정을 묻고 파일을 생성한 뒤 작업을 진행한다.
---

# Brief Morning

아침 업무 시작 루틴: 어제 작업 요약 및 PR 리뷰 목록 확인.

## 제약사항

- **정보 수집 및 요약만 진행** - 읽기 전용 작업이 원칙
- 단, `config.yaml`이 존재하지 않는 경우에 한해 **최초 1회 설정 파일 생성**은 허용

---

## STEP 0: 설정 읽기 (가장 먼저 실행)

스킬 디렉토리의 `config.yaml`을 읽어 이 머신의 설정을 파악한다.

```bash
cat ~/.config/agents/skills/brief-morning/config.yaml
```

### config.yaml이 있는 경우

파일 내용을 파싱하여 설정값을 확인하고, **enabled된 태스크만** 아래 병렬 실행 블록에서 수행한다.

### config.yaml이 없는 경우

`AskUserQuestion` tool을 사용해 사용자에게 직접 물어본다. 질문은 **한 번에 모두** 묻는다 (여러 번 나눠서 묻지 않는다):

**질문 1** — 수행할 작업 선택 (multiSelect: true)
- `daily_note` — 어제 Daily Note 확인
- `on_this_day` — 이날의 기록 (과거 같은 날짜)
- `git_status` — Git 로컬 상태 확인
- `github_pr` — GitHub PR 조회
- `gmail` — Gmail 받은편지함 요약
- `calendar` — Google Calendar 이번 주 일정

**질문 2** — `git_status`를 선택한 경우: Git root 경로 입력
- 예시 옵션: 자주 쓰는 경로 2~3개 + "직접 입력"

**질문 3** — `github_pr`를 선택한 경우: PR 조회할 저장소 목록 입력 (쉼표 구분)

> ⚠️ `git_status`나 `github_pr`를 선택하지 않았다면 해당 질문은 건너뛴다.

### config.yaml 생성

사용자 응답을 바탕으로 `~/.config/agents/skills/brief-morning/config.yaml`을 **Write tool**로 생성한다.

생성할 파일 형식:

```yaml
tasks:
  daily_note: true   # 사용자가 선택한 경우 true, 아니면 false
  on_this_day: true  # 사용자가 선택한 경우 true, 아니면 false
  git_status: false  # 사용자가 선택한 경우 true, 아니면 false
  github_pr: false   # 사용자가 선택한 경우 true, 아니면 false
  gmail: true        # 사용자가 선택한 경우 true, 아니면 false
  calendar: true     # 사용자가 선택한 경우 true, 아니면 false

git:
  root: "/Users/casper/Workspace"  # git_status 선택 시 사용자가 고른 경로, 아니면 빈 문자열
  exclude: []

github:
  repos: []  # github_pr 선택 시 사용자가 입력한 저장소 목록
```

파일 생성 후 사용자에게 다음 형식으로 안내한다:

```
✅ config.yaml이 생성되었습니다: ~/.config/agents/skills/brief-morning/config.yaml
다음 실행부터는 자동으로 이 설정을 사용합니다.
```

설정을 확인한 뒤, **enabled된 태스크만** 아래 병렬 실행 블록에서 수행한다.

---

## 실행 전략

**병렬 실행 필수**: enabled된 작업 그룹은 서로 독립적이므로 **반드시 동시에 실행**

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      PARALLEL EXECUTION BLOCK                                      │
├──────────────┬───────────────┬──────────────┬──────────────────┬───────────────┬───────────────────┤
│ TASK GROUP A │ TASK GROUP A' │ TASK GROUP B │  TASK GROUP C    │ TASK GROUP D  │   TASK GROUP E    │
│ (Daily Note) │ (이날의 기록) │ (Git Status) │ (GitHub PR 조회) │   (Gmail)     │    (Calendar)     │
├──────────────┼───────────────┼──────────────┼──────────────────┼───────────────┼───────────────────┤
│ tasks.       │ tasks.        │ tasks.       │ tasks.           │ tasks.        │ tasks.            │
│ daily_note   │ on_this_day   │ git_status   │ github_pr        │ gmail         │ calendar          │
│ = true 시    │ = true 시     │ = true 시    │ = true 시        │ = true 시     │ = true 시         │
│ 실행         │ 실행          │ 실행         │ 실행             │ 실행          │ 실행              │
└──────────────┴───────────────┴──────────────┴──────────────────┴───────────────┴───────────────────┘
```

---

## TASK GROUP A: Daily Note 확인

> **건너뛰기 조건**: `tasks.daily_note: false`

오늘을 제외한 가장 최신 daily note를 찾아 읽는다. 주말(토·일)이 포함된 경우 금요일까지 함께 탐색한다.

### 탐색 방법

```bash
# 1단계: 오늘을 제외하고 가장 최신 노트 찾기 (최대 14일 이전까지)
VAULT="/Users/casper/pkm/005 journals"
TODAY=$(date '+%Y-%m-%d')
LATEST=""
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
  D=$(date -v-${i}d '+%Y-%m-%d')
  Y=$(date -v-${i}d '+%Y')
  [ -f "$VAULT/$Y/$D.md" ] && LATEST="$D" && break
done

# 2단계: 찾은 노트가 주말(토=6, 일=0)이면 금요일까지 범위 확장
if [ -n "$LATEST" ]; then
  DOW=$(date -j -f '%Y-%m-%d' "$LATEST" '+%w')  # 0=일, 6=토
  if [ "$DOW" = "0" ] || [ "$DOW" = "6" ]; then
    # 주말이면 해당 주 금요일까지 탐색 (최대 2일 더 앞으로)
    COLLECT="$LATEST"
    for extra in 1 2; do
      D_PREV=$(date -j -f '%Y-%m-%d' -v-${extra}d "$LATEST" '+%Y-%m-%d')
      Y_PREV=$(date -j -f '%Y-%m-%d' -v-${extra}d "$LATEST" '+%Y')
      DOW_PREV=$(date -j -f '%Y-%m-%d' "$D_PREV" '+%w')
      [ -f "$VAULT/$Y_PREV/$D_PREV.md" ] && COLLECT="$D_PREV $COLLECT"
      [ "$DOW_PREV" = "5" ] && break  # 금요일 도달하면 중단
    done
    echo "$COLLECT"
  else
    echo "$LATEST"
  fi
fi
```

- 수집된 날짜 목록의 각 파일을 순서대로 읽어 요약
- 파일이 하나도 없으면 해당 섹션 생략
- 추출 정보: 완료한 작업, 진행 중인 작업, TODO

### 출력 형식

- 단일 노트(평일): `## 지난 일지 요약 (YYYY-MM-DD)`
- 복수 노트(주말 포함): `## 지난 일지 요약 (금 YYYY-MM-DD ~ 일 YYYY-MM-DD)` 형식으로 날짜 범위 명시
- 각 날짜별 내용을 날짜 헤더(`### YYYY-MM-DD (요일)`)로 구분하여 표시

---

## TASK GROUP A': 이날의 기록 (On This Day)

> **건너뛰기 조건**: `tasks.on_this_day: false`

오늘과 **같은 월-일(MM-DD)** 의 과거 연도 daily note를 모두 조회한다.

### 조회 방법

> ⚠️ Glob tool은 공백 포함 경로(`005 journals/`)에서 오동작하므로 **반드시 Bash로 조회**
> ⚠️ `find | grep` 파이프는 불안정할 수 있으므로 아래 for 루프 방식을 사용

```bash
TODAY_MMDD=$(date '+%m-%d')
CURRENT_YEAR=$(date '+%Y')
for dir in "/Users/casper/pkm/005 journals"/*/; do
  year=$(basename "$dir")
  [ "$year" = "$CURRENT_YEAR" ] && continue
  file="${dir}${year}-${TODAY_MMDD}.md"
  [ -f "$file" ] && echo "$file"
done | sort
```

- 파일 목록 확인 후 각 파일을 `obsidian read path="..."` 로 읽어 요약
- 올해 파일은 제외 (과거 연도만 대상)
- 파일이 존재하는 연도만 표시

### 요약 기준

- 각 파일에서 핵심 내용을 **1~2줄로 간략 요약**
- 주요 이벤트, 완료한 작업, 특이사항 위주
- 내용이 없거나 의미 있는 기록이 없으면 해당 연도 생략

---

## TASK GROUP D: Gmail 받은편지함 메일 요약

> **건너뛰기 조건**: `tasks.gmail: false`

work, personal 두 계정을 **동시에** 실행한다.

### 실행 명령

```bash
# work 계정
cd /Users/casper/.claude/skills/gmail-improved && \
  uv run python scripts/list_messages.py --account work --query "in:inbox newer_than:10d" --max 20

# personal 계정 (동시 실행)
cd /Users/casper/.claude/skills/gmail-improved && \
  uv run python scripts/list_messages.py --account personal --query "in:inbox newer_than:10d" --max 20
```

### 요약 기준

- 발신자 / 제목 / 수신 시각을 표 형식으로 정리
- 중요도가 높아 보이는 메일(공지, 리뷰 요청, 긴급 등)은 ⚠️ 표시
- 메일이 없으면 "받은편지함 메일 없음" 표시
- 메일 본문 내용은 읽지 않음 — 제목과 발신자로만 요약

---

## TASK GROUP E: Google Calendar 이번 주 일정 조회

> **건너뛰기 조건**: `tasks.calendar: false`

work, personal 두 계정을 **동시에** 실행한다.

### 실행 명령

```bash
# work 계정 — 이번 주(7일) 일정
cd /Users/casper/.claude/skills/google-calendar-improved && \
  uv run python scripts/fetch_events.py --account work --days 7

# personal 계정 — 이번 주(7일) 일정 (동시 실행)
cd /Users/casper/.claude/skills/google-calendar-improved && \
  uv run python scripts/fetch_events.py --account personal --days 7
```

### 요약 기준

- 날짜별로 그룹핑, 시간순 정렬
- 계정 구분: 🔵 work, 🟢 personal
- 오늘 일정은 **굵게** 강조
- 같은 시간대 work/personal 일정이 겹치면 ⚠️ 충돌 표시
- 일정 없는 날은 생략

---

## TASK GROUP B: Git 로컬 상태 확인

> **건너뛰기 조건**: `tasks.git_status: false`

### B-1. Worktree 목록 조회

`config.yaml`의 `git.root` 경로를 기준으로 worktree 목록을 조회한다.

```bash
# git.root 값을 사용 (예: /Users/casper/Workspace/goomba-hub)
cd {git.root} && git worktree list
```

### B-2. 각 Worktree 상태 확인 (B-1 결과 기반, 각각 병렬 실행)

**제외 대상**: `config.yaml`의 `git.exclude` 목록에 있는 worktree 이름

각 worktree에서 **동시에** 실행:

```bash
git branch --show-current
git status --porcelain
git log --oneline -5
git log origin/HEAD..HEAD --oneline 2>/dev/null || echo "(no upstream)"
```

---

## TASK GROUP C: GitHub PR 조회

> **건너뛰기 조건**: `tasks.github_pr: false`
> **저장소 목록**: `config.yaml`의 `github.repos` 배열 사용. 비어 있으면 이 섹션 생략.

### C-1. 내 PR 목록 조회 (repos 병렬)

```bash
gh pr list --author @me --repo {REPO} --state open \
  --json number,title,reviewDecision,mergeable,statusCheckRollup
```

### C-2. 리뷰 필요 PR 목록 조회 (repos 병렬)

```bash
gh pr list --repo {REPO} --state open --json number,title,author
```

결과에서 내가 작성한 PR 제외 (`author.login != @me`)

---

## 출력 형식

enabled된 섹션만 출력하고, disabled된 섹션은 완전히 생략한다.

```markdown
# 🌅 Morning Brief - YYYY-MM-DD

## 📅 이날의 기록 (On This Day)
> 과거 같은 날짜(MM-DD)의 기록을 돌아봅니다.

- **YYYY년** — [1~2줄 요약]
- **YYYY년** — [1~2줄 요약]

_(해당 날짜의 기록이 없으면 이 섹션 생략)_

## 📬 받은편지함 메일 요약

### 🔵 work (N개)
| 발신자 | 제목 | 수신 시각 |
|--------|------|-----------|
| ... | ... | ... |

### 🟢 personal (N개)
| 발신자 | 제목 | 수신 시각 |
|--------|------|-----------|
| ... | ... | ... |

_(받은편지함 메일이 없으면 "받은편지함 메일 없음" 표시)_

## 🗓️ 일정

### MM/DD (요일) — 오늘
- [HH:MM-HH:MM] 🔵 일정 제목 (work)
- [HH:MM-HH:MM] 🟢 일정 제목 (personal)

### MM/DD (요일)
- [HH:MM-HH:MM] 🔵 일정 제목 (work)

_(일정 없는 날은 생략, 충돌 시 ⚠️ 표시)_

## 지난 일지 요약
[요약 내용]

## 오늘 해야 할 일
[daily note에서 추출한 TODO 항목]

## 💻 로컬 작업 현황
| 경로 | 브랜치 | 미커밋 변경 | 미푸시 커밋 |
|------|--------|-------------|-------------|

## 📤 내 PR 현황
- 총 N개의 열린 PR
- 🟢 머지 가능: N개
- 🟡 리뷰 대기: N개
- 🔴 조치 필요: N개

### {repo_name}
| PR | 제목 | 리뷰 상태 | 머지 가능 | CI |
|----|------|-----------|-----------|-----|

## 📥 PR 리뷰 대기
- 총 N개의 PR 리뷰 필요

### {repo_name}
| PR | 제목 | 작성자 | 요약 |
|----|------|--------|------|
```
