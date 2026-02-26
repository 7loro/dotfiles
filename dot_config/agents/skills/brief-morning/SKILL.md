---
name: brief-morning
description: |
  아침 업무 시작 루틴: 어제 작업 요약 및 PR 리뷰 목록 확인.
  트리거: "아침 브리핑", "모닝 브리핑", "morning brief", "업무 시작", "/brief-morning" 등.
  읽기 전용 작업만 수행하며 파일 추가/삭제/수정 금지.
---

# Brief Morning

아침 업무 시작 루틴: 어제 작업 요약 및 PR 리뷰 목록 확인.

## 제약사항

- **절대 파일 추가, 삭제, 수정 금지** - 읽기 전용 작업만 수행
- 정보 수집 및 요약만 진행

## 실행 전략

**병렬 실행 필수**: 아래 6개 작업 그룹은 서로 독립적이므로 **반드시 동시에 실행**

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      PARALLEL EXECUTION BLOCK                                      │
├──────────────┬───────────────┬──────────────┬──────────────────┬───────────────┬───────────────────┤
│ TASK GROUP A │ TASK GROUP A' │ TASK GROUP B │  TASK GROUP C    │ TASK GROUP D  │   TASK GROUP E    │
│ (Daily Note) │ (이날의 기록) │ (Git Status) │ (GitHub PR 조회) │   (Gmail)     │    (Calendar)     │
├──────────────┼───────────────┼──────────────┼──────────────────┼───────────────┼───────────────────┤
│ 어제 노트    │ 과거 연도     │ git worktree │ 4개 저장소       │ work/personal │ work/personal     │
│ 읽기         │ 오늘 날짜     │ 각 상태 확인 │ gh CLI           │ 받은편지함    │ 이번 주 일정 조회 │
│              │ 노트 읽기     │              │ - 내 PR 목록     │ 요약          │                   │
│              │               │              │ - 리뷰 필요 PR   │               │                   │
└──────────────┴───────────────┴──────────────┴──────────────────┴───────────────┴───────────────────┘
```

---

## TASK GROUP A: Daily Note 확인

- `/Users/casper/pkm/005 journals/YYYY/` 에서 **어제 날짜**의 daily note 찾기
- 파일 경로 형식: `005 journals/YYYY/YYYY-MM-DD.md` (어제 날짜 기준)
- 추출 정보: 어제 완료한 작업, 진행 중인 작업, TODO

---

## TASK GROUP A': 이날의 기록 (On This Day)

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

- 파일 목록 확인 후 각 파일을 Read tool로 읽어 요약
- 올해 파일은 제외 (과거 연도만 대상)
- 파일이 존재하는 연도만 표시

### 요약 기준

- 각 파일에서 핵심 내용을 **1~2줄로 간략 요약**
- 주요 이벤트, 완료한 작업, 특이사항 위주
- 내용이 없거나 의미 있는 기록이 없으면 해당 연도 생략

---

## TASK GROUP D: Gmail 받은편지함 메일 요약

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

### B-1. Worktree 목록 조회

```bash
cd /Users/casper/Workspace/goomba-hub && git worktree list
```

### B-2. 각 Worktree 상태 확인 (B-1 결과 기반, 각각 병렬 실행)

**제외 대상**: `goomba-hub-review` (PR 리뷰 전용 worktree)

각 worktree에서 **동시에** 실행:

```bash
git branch --show-current
git status --porcelain
git log --oneline -5
git log origin/HEAD..HEAD --oneline 2>/dev/null || echo "(no upstream)"
```

---

## TASK GROUP C: GitHub PR 조회

### 대상 저장소

```
REPOS=(
  "github.kakaocorp.com/kjk/goomba-hub"
  "github.kakaocorp.com/kjk/flutter_epub_viewer"
  "github.kakaocorp.com/kjk/pluto_grid"
  "github.kakaocorp.com/kjk/flutter_ocr"
)
```

### C-1. 내 PR 목록 조회 (4개 저장소 병렬)

```bash
gh pr list --author @me --repo {REPO} --state open \
  --json number,title,reviewDecision,mergeable,statusCheckRollup
```

### C-2. 리뷰 필요 PR 목록 조회 (4개 저장소 병렬)

```bash
gh pr list --repo {REPO} --state open --json number,title,author
```

결과에서 내가 작성한 PR 제외 (`author.login != @me`)

---

## 출력 형식

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

## 🗓️ 이번 주 일정

### MM/DD (요일) — 오늘
- [HH:MM-HH:MM] 🔵 일정 제목 (work)
- [HH:MM-HH:MM] 🟢 일정 제목 (personal)

### MM/DD (요일)
- [HH:MM-HH:MM] 🔵 일정 제목 (work)

_(일정 없는 날은 생략, 충돌 시 ⚠️ 표시)_

## 어제 작업 요약
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
