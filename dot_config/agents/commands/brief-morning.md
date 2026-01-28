---
description: 아침 업무 시작 루틴 (어제 작업 요약 및 PR 리뷰 목록 확인)
model: anthropic/claude-sonnet-4-5
---
# brief-morning

아침 업무 시작 루틴: 어제 작업 요약 및 PR 리뷰 목록 확인

## 제약사항

- **절대 파일 추가, 삭제, 수정 금지** - 읽기 전용 작업만 수행
- 정보 수집 및 요약만 진행

## 실행 전략

**🚀 병렬 실행 필수**: 아래 3개 작업 그룹은 서로 독립적이므로 **반드시 동시에 실행**

```
┌─────────────────────────────────────────────────────────────────┐
│                    PARALLEL EXECUTION BLOCK                      │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   TASK GROUP A  │   TASK GROUP B  │       TASK GROUP C          │
│   (Daily Note)  │  (Git Status)   │    (GitHub PR 조회)          │
├─────────────────┼─────────────────┼─────────────────────────────┤
│ PKM 노트 읽기    │ git worktree    │ 4개 저장소 gh CLI 동시 호출   │
│                 │ 각 worktree 상태 │ - 내 PR 목록                 │
│                 │                 │ - 리뷰 필요 PR 목록           │
└─────────────────┴─────────────────┴─────────────────────────────┘
```

---

## TASK GROUP A: Daily Note 확인

**독립 작업 - 다른 그룹과 병렬 실행**

- `/Users/casper/PKM/005 journals/YYYY/` 디렉토리에서 **어제 날짜**의 daily note 찾기
- 파일 경로 형식: `005 journals/YYYY/YYYY-MM-DD.md` (어제 날짜 기준)
- 파일 내용을 읽고 다음 정보 추출:
  - 어제 완료한 작업
  - 진행 중인 작업
  - 해야 할 일 (TODO)

---

## TASK GROUP B: Git 로컬 상태 확인

**독립 작업 - 다른 그룹과 병렬 실행**

### B-1. Worktree 목록 조회 (먼저 실행)

```bash
# 메인 디렉토리에서 실행
cd /Users/casper/Workspace/goomba-hub && git worktree list
```

### B-2. 각 Worktree 상태 확인 (B-1 결과 기반, 각각 병렬 실행)

각 worktree 경로에서 **동시에** 다음 명령 실행:

```bash
# 각 worktree에서 병렬 실행
git branch --show-current
git status --porcelain
git log --oneline -5
git log origin/HEAD..HEAD --oneline 2>/dev/null || echo "(no upstream)"
```

---

## TASK GROUP C: GitHub PR 조회

**독립 작업 - 다른 그룹과 병렬 실행**

### 대상 저장소 (4개 동시 조회)

```
REPOS=(
  "github.kakaocorp.com/kjk/goomba-hub"
  "github.kakaocorp.com/kjk/flutter_epub_viewer"
  "github.kakaocorp.com/kjk/pluto_grid"
  "github.kakaocorp.com/kjk/flutter_ocr"
)
```

### C-1. 내 PR 목록 조회 (4개 저장소 병렬)

각 저장소에 대해 **동시에** 실행:

```bash
gh pr list --author @me --repo {REPO} --state open --json number,title,reviewDecision,mergeable,statusCheckRollup
```

### C-2. 리뷰 필요 PR 목록 조회 (4개 저장소 병렬)

각 저장소에 대해 **동시에** 실행:

```bash
gh pr list --repo {REPO} --state open --json number,title,author
```

결과에서 내가 작성한 PR 제외 (`author.login != @me`)

---

## 출력 형식

### 📓 Daily Note (YYYY-MM-DD)
```
- [노트 내용 요약]
```

### 💻 로컬 작업 현황
```
| 경로 | 브랜치 | 미커밋 변경 | 미푸시 커밋 |
|------|--------|-------------|-------------|
| ... | ... | ... | ... |
```

### 📤 내가 작성한 PR 현황
```
### {repo_name}
| PR | 제목 | 리뷰 상태 | 머지 가능 | CI | 비고 |
|----|------|-----------|-----------|----|----- |
| #123 | [제목] | ✅ Approved | ✅ 가능 | ✅ 통과 | 머지 가능! |
| #456 | [제목] | 🔄 대기중 | ⚠️ 충돌 | ✅ 통과 | 충돌 해결 필요 |

(작성한 PR이 없는 저장소는 생략)
```

### 📥 PR 리뷰 필요 목록
```
### {repo_name}
| PR | 제목 | 작성자 | 요약 |
|----|------|--------|------|
| #123 | [제목] | @author | [변경사항 요약] |

(리뷰 필요한 PR이 없는 저장소는 생략)
```

---

## 최종 출력

모든 병렬 작업 완료 후 종합하여 브리핑:

```
# 🌅 Morning Brief - YYYY-MM-DD

## 어제 작업 요약
[요약 내용]

## 오늘 해야 할 일
[daily note에서 추출한 TODO 항목]

## 💻 로컬 작업 현황
[각 worktree 상태 테이블]

## 📤 내 PR 현황
- 총 N개의 열린 PR
- 🟢 머지 가능: N개
- 🟡 리뷰 대기: N개
- 🔴 조치 필요: N개 (충돌, CI 실패, 변경 요청 등)
[상세 목록]

## 📥 PR 리뷰 대기
- 총 N개의 PR 리뷰 필요
[PR 목록 및 요약]
```
