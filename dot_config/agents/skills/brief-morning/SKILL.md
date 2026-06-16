---
name: brief-morning
description: |
  아침 업무 시작 루틴: 어제 작업 요약, PR 리뷰 목록 확인.
  트리거: "아침 브리핑", "모닝 브리핑", "morning brief", "업무 시작", "/brief-morning" 등.
  config.yaml이 없으면 사용자에게 설정을 묻고 파일을 생성한 뒤 작업을 진행한다.
allowed-tools: Bash(agent-browser:*), Bash(npx agent-browser:*)
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
- `on_this_day` — 이날의 기록 (과거 같은 날짜)
- `calendar` — Google Calendar 이번 주 일정
- `gmail` — Gmail 받은편지함 요약
- `daily_note` — 어제 Daily Note 확인
- `git_status` — Git 로컬 상태 확인
- `github_pr` — GitHub PR 조회

**질문 2** — `git_status`를 선택한 경우: 작업 베이스 디렉토리 입력 (이 디렉토리 아래 git repo들을 자동 탐색)
- 예시 옵션: `~/Workspace` 등 자주 쓰는 베이스 경로 2~3개 + "직접 입력"
- `recent_days`는 기본 30으로 설정 (최근 30일 내 커밋이 있는 repo만 점검)

**질문 3** — `github_pr`를 선택한 경우: PR 조회할 저장소 목록 입력 (쉼표 구분)

> ⚠️ `git_status`나 `github_pr`를 선택하지 않았다면 해당 질문은 건너뛴다.

### config.yaml 생성

사용자 응답을 바탕으로 `~/.config/agents/skills/brief-morning/config.yaml`을 **Write tool**로 생성한다.

생성할 파일 형식:

```yaml
tasks:
  on_this_day: true  # 사용자가 선택한 경우 true, 아니면 false
  calendar: true     # 사용자가 선택한 경우 true, 아니면 false
  gmail: true        # 사용자가 선택한 경우 true, 아니면 false
  daily_note: true   # 사용자가 선택한 경우 true, 아니면 false
  git_status: false  # 사용자가 선택한 경우 true, 아니면 false
  github_pr: false   # 사용자가 선택한 경우 true, 아니면 false

git:
  # ~/Workspace 아래에서 최근 recent_days일 내 커밋이 있는 git repo를 자동 탐색해 worktree 상태를 점검
  workspace: "/Users/casper/Workspace"  # git_status 선택 시 사용자가 고른 베이스 경로, 아니면 빈 문자열
  recent_days: 30                       # 최근 활동 판단 기준 일수
  exclude: []                           # 점검에서 제외할 repo 디렉토리명 목록

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

**Agent 기반 병렬 실행**: enabled된 작업 그룹은 서로 독립적이므로 **Agent tool을 사용하여 반드시 동시에 실행**한다.

### 실행 그룹 분류

> ⚡ **속도 최적화**: Agent 수를 최소화하고, 데이터 수집용 Agent에는 `model: "sonnet"`을 지정한다.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        메인 컨텍스트 (직접 실행)                         │
│  TASK GROUP A (이날의 기록) + TASK GROUP E (지난 일지)                    │
│  → 로컬 파일 읽기만 하므로 Agent 생성 오버헤드 없이 직접 처리            │
│  → 파일 탐색은 단일 Bash 호출로 A + E를 동시 수행                       │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────┬──────────────────────────┐
│   Agent 1 (sonnet)       │   Agent 2 (sonnet)       │
│  TASK GROUP B + C        │  TASK GROUP F + G        │
│  (일정 + 메일)           │  (Git 상태 + GitHub PR)  │
└──────────────────────────┴──────────────────────────┘
```

### 실행 방법

1. **메인 컨텍스트**: TASK GROUP A + E 파일 탐색을 **단일 Bash 호출**로 동시 수행
2. **Agent 병렬 실행**: 나머지 enabled된 그룹을 **하나의 메시지에서 2개 Agent를 동시 호출**
   - **Agent 1** (`model: "sonnet"`): Calendar + Gmail — 동일 Python 스크립트 기반, 4개 명령을 하나의 Bash `&`로 실행
   - **Agent 2** (`model: "sonnet"`): Git 상태 + GitHub PR — 동일 CLI 기반, Bash `&`로 병렬 실행
   - Agent 결과를 취합하여 최종 출력 생성

> ⚠️ **반드시 하나의 메시지에서 2개 Agent를 동시 호출**해야 진정한 병렬 실행이 됨. 순차 호출하면 안 됨.
> ⚡ 두 Agent 모두 데이터 수집+포맷팅만 수행하므로 `model: "sonnet"` 지정으로 응답 속도를 높인다.

---

## TASK GROUP A: 이날의 기록 (On This Day)

> **건너뛰기 조건**: `tasks.on_this_day: false`

오늘과 **같은 월-일(MM-DD)** 의 과거 연도 daily note를 모두 조회한다.

### 조회 방법

> ⚠️ Glob tool은 공백 포함 경로(`005 journals/`)에서 오동작하므로 **반드시 Bash로 조회**
> ⚡ TASK GROUP E (지난 일지)의 파일 탐색과 **단일 Bash 호출로 동시 수행**하여 Bash tool 호출을 1회로 줄인다.

```bash
VAULT="/Users/casper/pkm/005 journals"
TODAY_MMDD=$(date '+%m-%d')
CURRENT_YEAR=$(date '+%Y')
TODAY=$(date '+%Y-%m-%d')

# === A: On This Day (과거 같은 날짜) ===
echo "=== ON_THIS_DAY ==="
for dir in "$VAULT"/*/; do
  year=$(basename "$dir")
  [ "$year" = "$CURRENT_YEAR" ] && continue
  file="${dir}${year}-${TODAY_MMDD}.md"
  [ -f "$file" ] && echo "$file"
done | sort

# === E: Latest Daily Note ===
echo "=== LATEST_DAILY ==="
LATEST=""
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
  D=$(date -v-${i}d '+%Y-%m-%d')
  Y=$(date -v-${i}d '+%Y')
  [ -f "$VAULT/$Y/$D.md" ] && LATEST="$D" && break
done
if [ -n "$LATEST" ]; then
  DOW=$(date -j -f '%Y-%m-%d' "$LATEST" '+%w')
  if [ "$DOW" = "0" ] || [ "$DOW" = "6" ]; then
    COLLECT="$LATEST"
    for extra in 1 2; do
      D_PREV=$(date -j -f '%Y-%m-%d' -v-${extra}d "$LATEST" '+%Y-%m-%d')
      Y_PREV=$(date -j -f '%Y-%m-%d' -v-${extra}d "$LATEST" '+%Y')
      DOW_PREV=$(date -j -f '%Y-%m-%d' "$D_PREV" '+%w')
      [ -f "$VAULT/$Y_PREV/$D_PREV.md" ] && COLLECT="$D_PREV $COLLECT"
      [ "$DOW_PREV" = "5" ] && break
    done
    echo "$COLLECT"
  else
    echo "$LATEST"
  fi
fi
```

- 출력의 `=== ON_THIS_DAY ===` 이후 줄들이 A의 파일 목록, `=== LATEST_DAILY ===` 이후 줄이 E의 날짜 목록
- 이 결과를 파싱한 뒤, 모든 파일을 **Read tool 병렬 호출**로 한 번에 읽는다
- 올해 파일은 제외 (과거 연도만 대상)
- 파일이 존재하는 연도만 표시

### 요약 기준

- 각 파일에서 핵심 내용을 **1~2줄로 간략 요약**
- 주요 이벤트, 완료한 작업, 특이사항 위주
- 내용이 없거나 의미 있는 기록이 없으면 해당 연도 생략

---

## TASK GROUP B+C: Google Calendar + Gmail (Agent 1, `model: "sonnet"`)

> **건너뛰기 조건**: `tasks.calendar: false` AND `tasks.gmail: false` 둘 다 false면 이 Agent 생략
> ⚡ Calendar과 Gmail은 동일 Python 스크립트 기반이므로 **하나의 Agent에서 단일 Bash 호출**로 4개 명령을 동시 실행한다.

### 실행 명령

Calendar과 Gmail의 work/personal 4개 스크립트를 **하나의 Bash에서 `&`로 동시 실행**한다:

```bash
CAL_DIR="/Users/casper/.claude/skills/google-calendar-improved"
GMAIL_DIR="/Users/casper/.claude/skills/gmail-improved"

# Calendar + Gmail 4개 동시 실행
cd "$CAL_DIR" && uv run python scripts/fetch_events.py --account work --days 7 > /tmp/cal_work.txt 2>&1 &
cd "$CAL_DIR" && uv run python scripts/fetch_events.py --account personal --days 7 > /tmp/cal_personal.txt 2>&1 &
cd "$GMAIL_DIR" && uv run python scripts/list_messages.py --account work --query "in:inbox newer_than:10d" --max 20 > /tmp/gmail_work.txt 2>&1 &
cd "$GMAIL_DIR" && uv run python scripts/list_messages.py --account personal --query "in:inbox newer_than:10d" --max 20 > /tmp/gmail_personal.txt 2>&1 &
wait

echo "=== CAL_WORK ===" && cat /tmp/cal_work.txt
echo "=== CAL_PERSONAL ===" && cat /tmp/cal_personal.txt
echo "=== GMAIL_WORK ===" && cat /tmp/gmail_work.txt
echo "=== GMAIL_PERSONAL ===" && cat /tmp/gmail_personal.txt
```

### Calendar 요약 기준

- 날짜별로 그룹핑, 시간순 정렬
- 계정 구분: 🔵 work, 🟢 personal
- 오늘 일정은 **굵게** 강조
- 같은 시간대 work/personal 일정이 겹치면 ⚠️ 충돌 표시
- 일정 없는 날은 생략

### Gmail 요약 기준

- 발신자 / 제목 / 수신 시각을 표 형식으로 정리
- 중요도가 높아 보이는 메일(공지, 리뷰 요청, 긴급 등)은 ⚠️ 표시
- 메일이 없으면 "받은편지함 메일 없음" 표시
- 메일 본문 내용은 읽지 않음 — 제목과 발신자로만 요약

---

## TASK GROUP E: Daily Note 확인

> **건너뛰기 조건**: `tasks.daily_note: false`
> ⚡ 파일 탐색은 TASK GROUP A의 통합 Bash 스크립트에서 이미 수행됨. `=== LATEST_DAILY ===` 결과를 사용.

오늘을 제외한 가장 최신 daily note를 읽는다. 주말(토·일)이 포함된 경우 금요일까지 함께 읽는다.

- 수집된 날짜 목록의 각 파일을 **TASK GROUP A 파일들과 함께 Read tool 병렬 호출**로 읽어 요약
- 파일이 하나도 없으면 해당 섹션 생략
- 추출 정보: 완료한 작업, 진행 중인 작업, TODO

### 출력 형식

- 단일 노트(평일): `## 지난 일지 요약 (YYYY-MM-DD)`
- 복수 노트(주말 포함): `## 지난 일지 요약 (금 YYYY-MM-DD ~ 일 YYYY-MM-DD)` 형식으로 날짜 범위 명시
- 각 날짜별 내용을 날짜 헤더(`### YYYY-MM-DD (요일)`)로 구분하여 표시

---

## TASK GROUP F+G: Git 상태 + GitHub PR (Agent 3, `model: "sonnet"`)

> **건너뛰기 조건**: `tasks.git_status: false` AND `tasks.github_pr: false` 둘 다 false면 이 Agent 생략
> ⚡ Git 상태와 GitHub PR은 동일 CLI 기반이므로 **하나의 Agent에서 처리**한다.

### F: Git 로컬 상태 확인

명시 경로를 나열하는 대신, `config.yaml`의 `git.workspace` 아래에서 **최근 `git.recent_days`일 내 커밋이 있는 git repo를 자동 탐색**한 뒤, 각 repo의 worktree 상태를 확인한다. ("최근 작업한 프로젝트"만 자동으로 골라냄)

- **탐색 범위**: `git.workspace` 최상위 + 그룹 폴더(`ax/` 등) 한 단계 하위. repo 내부로는 들어가지 않으므로 서브모듈 노이즈가 없다.
- **활동 신호**: 마지막 커밋 시각(`git log -1 --format=%ct`)이 `recent_days`일 이내.
- **제외 대상**: `git.exclude` 목록에 있는 repo 디렉토리명.
- **worktree 펼치기**: 탐색된 각 repo에서 `git worktree list`로 linked worktree까지 모두 점검.

아래 스크립트를 **단일 Bash 호출**로 실행한다 (config 값은 실제 설정으로 치환):

```bash
# 매칭 없는 글로브를 빈 목록으로 (zsh/bash 공통) — 하위 폴더 없는 디렉토리에서 에러 방지
setopt null_glob 2>/dev/null; shopt -s nullglob 2>/dev/null

WORKSPACE="/Users/casper/Workspace"   # config: git.workspace
RECENT_DAYS=30                          # config: git.recent_days
EXCLUDE=()                              # config: git.exclude (repo 디렉토리명, 예: ("goomba-hub-review"))

CUTOFF=$(( $(date +%s) - RECENT_DAYS * 86400 ))

# 1단계: repo 루트 후보 수집 (depth 1: repo면 자기 자신 / 아니면 그룹폴더로 보고 depth 2 하위만)
CANDIDATES=()
for d1 in "$WORKSPACE"/*/; do
  if [ -e "${d1}.git" ]; then
    CANDIDATES+=("${d1%/}")
  else
    for d2 in "$d1"*/; do
      [ -e "${d2}.git" ] && CANDIDATES+=("${d2%/}")
    done
  fi
done

# 2단계: 최근 커밋 있는 repo만 필터 (exclude 제거)
RECENT_REPOS=()
for repo in "${CANDIDATES[@]}"; do
  name=$(basename "$repo")
  skip=""
  for ex in "${EXCLUDE[@]}"; do [ "$name" = "$ex" ] && skip=1; done
  [ -n "$skip" ] && continue
  ts=$(git -C "$repo" log -1 --format=%ct 2>/dev/null) || continue
  [ -n "$ts" ] && [ "$ts" -ge "$CUTOFF" ] && RECENT_REPOS+=("$repo")
done
echo "SCANNED_RECENT_REPOS: ${#RECENT_REPOS[@]} (최근 ${RECENT_DAYS}일 내 커밋)"

# 3단계: 각 repo의 worktree를 펼쳐 상태 병렬 확인
for repo in "${RECENT_REPOS[@]}"; do
  while IFS= read -r wt; do
    [ -n "$wt" ] || continue
    (
      echo "=== $wt ==="
      cd "$wt" && \
      echo "BRANCH: $(git branch --show-current)" && \
      echo "STATUS:" && git status --porcelain && \
      echo "UNPUSHED:" && (git log @{u}..HEAD --oneline 2>/dev/null || echo "(no upstream)")
    ) &
  done < <(git -C "$repo" worktree list --porcelain | awk '/^worktree /{print $2}')
done
wait
```

**보고 기준**: 미커밋 변경(STATUS) 또는 미푸시 커밋(UNPUSHED)이 **하나라도 있는 worktree만** 표에 표시한다. 완전히 깨끗한 worktree는 생략하고, 스캔한 repo 개수(`SCANNED_RECENT_REPOS`)만 요약에 적는다. pending이 전혀 없으면 "정리 안 된 로컬 작업 없음"으로 표시.

### G: GitHub PR 조회

**저장소 목록**: `config.yaml`의 `github.repos` 배열 사용. 비어 있으면 이 섹션 생략.

모든 repo를 **하나의 Bash에서 `&`로 병렬 실행**한다:

```bash
# config.yaml의 github.repos 값 사용
REPOS=("kjk/goomba-hub" "kjk/flutter_epub_viewer" "kjk/flutter_ocr" "kjk/akira_bot")

for repo in "${REPOS[@]}"; do
  (
    echo "=== $repo - MY PRS ==="
    gh pr list --author @me --repo "$repo" --state open \
      --json number,title,reviewDecision,mergeable,statusCheckRollup 2>&1
    echo "=== $repo - REVIEW NEEDED ==="
    gh pr list --repo "$repo" --state open --json number,title,author 2>&1
  ) &
done
wait
```

G 결과에서 내가 작성한 PR 제외 (`author.login != @me`)

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

## 🗓️ 일정

### MM/DD (요일) — 오늘
- [HH:MM-HH:MM] 🔵 일정 제목 (work)
- [HH:MM-HH:MM] 🟢 일정 제목 (personal)

### MM/DD (요일)
- [HH:MM-HH:MM] 🔵 일정 제목 (work)

_(일정 없는 날은 생략, 충돌 시 ⚠️ 표시)_

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

## 지난 일지 요약
[요약 내용]

## 오늘 해야 할 일
[daily note에서 추출한 TODO 항목]

## 💻 로컬 작업 현황
> 최근 N일 내 활동 repo M개 스캔 (~/Workspace 자동 탐색)

| 경로 | 브랜치 | 미커밋 변경 | 미푸시 커밋 |
|------|--------|-------------|-------------|

_(미커밋·미푸시가 있는 worktree만 표시. 전부 깨끗하면 "정리 안 된 로컬 작업 없음")_

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
