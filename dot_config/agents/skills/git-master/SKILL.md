---
name: git-master
description: |
  Git 전문가 스킬. Atomic commit 분할, rebase/squash, history 검색(blame, bisect, log -S)을 수행.
  트리거: "git-master", "/git-master", "atomic commit", "커밋 분할", "커밋 나눠", "rebase", "리베이스",
  "squash", "스쿼시", "히스토리 정리", "history cleanup", "git blame", "bisect", "누가 바꿨어",
  "언제 바뀌었", "find when", "who changed", "커밋 정리", "변경사항 정리해서 커밋".
  git-master는 다수 파일을 atomic 단위로 분할 커밋하고 rebase/history 검색까지 수행하는 종합 Git 전문가.
---

# Git Master

3가지 전문 영역을 결합한 Git 전문가:
1. **Commit Architect**: Atomic commit 분할, 의존성 순서, 스타일 감지
2. **Rebase Surgeon**: History rewriting, conflict resolution, branch cleanup
3. **History Archaeologist**: 특정 변경이 언제/어디서 도입됐는지 추적

---

## 모드 감지 (최초 단계)

| 요청 패턴 | 모드 | 이동 |
|-----------|------|------|
| "commit", "커밋", 변경사항 커밋 | `COMMIT` | Phase 0-6 |
| "rebase", "리베이스", "squash", "히스토리 정리" | `REBASE` | Phase R1-R4 |
| "find when", "who changed", "언제 바뀌었", "git blame", "bisect" | `HISTORY_SEARCH` | Phase H1-H3 |

**요청을 정확히 파싱할 것. COMMIT 모드를 기본으로 가정하지 말 것.**

---

## 핵심 원칙: 다수 커밋이 기본 (비타협)

```
3+ 파일 변경 -> 최소 2 커밋 (예외 없음)
5+ 파일 변경 -> 최소 3 커밋 (예외 없음)
10+ 파일 변경 -> 최소 5 커밋 (예외 없음)
```

**분할 기준:**

| 기준 | 액션 |
|------|------|
| 다른 디렉토리/모듈 | 분할 |
| 다른 컴포넌트 타입 (model/service/view) | 분할 |
| 독립적으로 revert 가능 | 분할 |
| 다른 관심사 (UI/로직/설정/테스트) | 분할 |
| 신규 파일 vs 수정 | 분할 |

**결합 조건 (모두 충족 시만):**
- 동일한 atomic 단위 (예: 함수 + 해당 테스트)
- 분리 시 컴파일 불가
- 한 문장으로 이유 설명 가능

---

## COMMIT 모드 (Phase 0-6)

### Phase 0: 병렬 컨텍스트 수집

아래 명령을 **병렬 실행**:

```bash
# 그룹 1: 현재 상태
git status
git diff --staged --stat
git diff --stat

# 그룹 2: 히스토리
git log -30 --oneline
git log -30 --pretty=format:"%s"

# 그룹 3: 브랜치 컨텍스트
git branch --show-current
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NO_UPSTREAM"
git log --oneline $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD 2>/dev/null
```

### Phase 1: 스타일 감지 (BLOCKING - 반드시 출력 후 진행)

#### 1.1 언어 감지

최근 30개 커밋에서 한국어/영어 비율 계산. 50% 이상인 쪽 사용.

#### 1.2 커밋 스타일 분류

| 스타일 | 패턴 | 예시 | 감지 정규식 |
|--------|------|------|------------|
| `SEMANTIC` | `type: message` | `feat: add login` | `/^(feat\|fix\|chore\|refactor\|docs\|test\|ci\|style\|perf\|build)(\(.+\))?:/` |
| `PLAIN` | 설명만 | `Add login feature` | 접두사 없음, 3단어 초과 |
| `SHORT` | 최소 키워드 | `format`, `lint` | 1-3 단어 |

감지 알고리즘: semantic 50%+ → SEMANTIC, plain 50%+ → PLAIN, short 33%+ → SHORT, 그 외 → PLAIN.

#### 1.3 필수 출력

```
STYLE DETECTION RESULT
======================
Language: [KOREAN | ENGLISH]
Style: [SEMANTIC | PLAIN | SHORT]
Reference examples:
  1. "실제 커밋 메시지"
  2. "실제 커밋 메시지"
  3. "실제 커밋 메시지"
```

### Phase 2: 브랜치 컨텍스트 분석

```
IF main/master -> NEW_COMMITS_ONLY (절대 rewrite 금지)
ELSE IF commits_ahead == 0 -> NEW_COMMITS_ONLY
ELSE IF 모든 커밋 로컬 -> AGGRESSIVE_REWRITE (fixup, reset 허용)
ELSE IF push 됨 + 미병합 -> CAREFUL_REWRITE (force push 경고)
```

### Phase 3: Atomic 단위 계획 (BLOCKING - 반드시 출력 후 진행)

#### 3.1 최소 커밋 수 계산

`min_commits = ceil(file_count / 3)`

#### 3.2 분할 우선순위

1. **디렉토리/모듈별 분할** (1차)
2. **관심사별 분할** (2차: 같은 디렉토리 내)
3. **테스트 + 구현 페어링** (필수: 테스트는 구현과 같은 커밋)

#### 3.3 필수 정당화

3+ 파일 커밋마다 반드시 한 문장으로 이유 명시.

유효한 이유: "구현 파일 + 직접 테스트", "타입 정의 + 유일한 소비자", "마이그레이션 + 모델 변경"
무효한 이유: "기능 X와 관련", "같은 PR의 일부", "함께 변경됨"

#### 3.4 의존성 순서

```
Level 0: 유틸, 상수, 타입 정의
Level 1: 모델, 스키마, 인터페이스
Level 2: 서비스, 비즈니스 로직
Level 3: API 엔드포인트, 컨트롤러
Level 4: 설정, 인프라
커밋 순서: Level 0 -> 1 -> 2 -> 3 -> 4
```

#### 3.5 필수 출력

```
COMMIT PLAN
===========
Files changed: N
Minimum commits required: M
Planned commits: K (K >= M: PASS)

COMMIT 1: [감지된 스타일로 메시지]
  - path/to/file1.py
  - path/to/file1_test.py
  Justification: 구현 + 테스트

COMMIT 2: [메시지]
  - path/to/file2.py
  Justification: 독립 유틸리티

Execution order: Commit 1 -> Commit 2 -> ...
```

### Phase 4: 커밋 전략 결정

```
FIXUP: 기존 커밋 보완, 같은 기능의 누락/버그 수정, 리뷰 피드백 반영
NEW COMMIT: 새 기능, 독립 단위, 다른 이슈
RESET & REBUILD: 히스토리가 지저분 + 모든 커밋 로컬일 때만
```

### Phase 5: 커밋 실행

```bash
# Fixup 커밋
git add <files>
git commit --fixup=<target-hash>
MERGE_BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $MERGE_BASE

# New 커밋 (의존성 순서대로)
git add <file1> <file2>
git diff --staged --stat
git commit -m "<스타일에 맞는 메시지>"
git log -1 --oneline
```

### Phase 6: 검증 및 보고

```bash
git status
git log --oneline $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)..HEAD
```

최종 보고:
```
COMMIT SUMMARY:
  Strategy: <사용된 전략>
  Commits created: N
  Fixups merged: M

HISTORY:
  <hash> <message>
  ...

NEXT STEPS:
  - git push [--force-with-lease]
```

---

## REBASE 모드 (Phase R1-R4)

### Phase R1: 컨텍스트 분석

```bash
git branch --show-current
git log --oneline -20
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NO_UPSTREAM"
git status --porcelain
```

안전성 평가:

| 조건 | 위험 | 액션 |
|------|------|------|
| main/master | CRITICAL | **중단** - main에서 rebase 금지 |
| dirty working directory | WARNING | 먼저 stash |
| push된 커밋 존재 | WARNING | force-push 필요, 사용자 확인 |
| 모든 커밋 로컬 | SAFE | 자유롭게 진행 |

전략 결정: "squash/정리" → INTERACTIVE_SQUASH, "rebase on main" → REBASE_ONTO_BASE, "autosquash" → AUTOSQUASH

### Phase R2: Rebase 실행

```bash
# Squash (전체 합치기)
MERGE_BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
git reset --soft $MERGE_BASE
git commit -m "Combined: <요약>"

# Autosquash (fixup! 커밋 자동 병합)
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $MERGE_BASE

# Rebase onto (브랜치 업데이트)
git fetch origin
git rebase origin/main
```

충돌 처리: `git status`로 확인 → 파일 편집으로 해결 → `git add` → `git rebase --continue`
복구: `git rebase --abort` (안전 롤백), `git reflog`으로 원래 커밋 찾기

### Phase R3-R4: 검증 및 보고

```bash
git status
git log --oneline $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)..HEAD
git diff ORIG_HEAD..HEAD --stat
```

Push: 미push → `git push -u origin <branch>`, 이미 push → `git push --force-with-lease`

---

## HISTORY SEARCH 모드 (Phase H1-H3)

### Phase H1: 검색 유형 결정

| 요청 | 검색 유형 | 도구 |
|------|----------|------|
| "X 언제 추가됐어" | PICKAXE | `git log -S` |
| "X 패턴 변경 커밋" | REGEX | `git log -G` |
| "이 줄 누가 썼어" | BLAME | `git blame` |
| "버그 언제 생겼어" | BISECT | `git bisect` |
| "파일 히스토리" | FILE_LOG | `git log -- path` |
| "삭제된 코드 찾기" | PICKAXE_ALL | `git log -S --all` |

### Phase H2: 검색 실행

```bash
# Pickaxe: 문자열 추가/제거 커밋 찾기
git log -S "searchString" --oneline
git log -S "searchString" -p              # 변경 내용 포함
git log -S "searchString" --all --oneline # 모든 브랜치

# Regex: diff에서 패턴 매칭
git log -G "pattern.*regex" --oneline

# Blame: 라인별 귀속
git blame -L 10,20 path/to/file.py
git blame -C path/to/file.py             # 이동/복사 추적

# Bisect: 버그 도입 커밋 이진 검색
git bisect start && git bisect bad && git bisect good <tag>
git bisect run <test-command>             # 자동화

# File log: 파일 히스토리
git log --follow --oneline -- path/to/file.py
```

`-S` vs `-G`: `-S`는 문자열 개수 변화 감지, `-G`는 diff에서 패턴 매칭.

### Phase H3: 결과 제시

```
SEARCH RESULTS:
  Query: "<검색 내용>"
  Type: <PICKAXE | REGEX | BLAME | BISECT | FILE_LOG>

  Commit       Date           Message
  ---------    ----------     --------------------------------
  abc1234      2024-06-15     feat: add discount calculation

MOST RELEVANT: abc1234
  Author: John Doe
  Files changed: 3

ACTIONS:
  - git show abc1234        (전체 커밋 보기)
  - git revert abc1234      (되돌리기)
  - git cherry-pick abc1234 (다른 브랜치에 적용)
```

---

## 안티패턴 (자동 실패)

1. **한 커밋에 다수 파일** - 3+ 파일은 반드시 2+ 커밋으로 분할
2. **semantic 스타일 기본 적용** - 반드시 git log에서 감지 후 결정
3. **테스트와 구현 분리** - 항상 같은 커밋
4. **파일 타입별 그룹화** - 기능/모듈별로 그룹화
5. **push된 히스토리 무단 rewrite** - 명시적 허락 없이 금지
6. **`--force` 사용** - 항상 `--force-with-lease` 사용
7. **정당화 없는 그룹화** - "관련됨"은 유효하지 않음
