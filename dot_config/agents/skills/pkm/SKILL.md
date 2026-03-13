---
name: pkm
description: |
  Obsidian PKM vault 관리 스킬. 노트 생성/편집/검색, Daily Journal 관리, PR 문서화, 책/영화 노트 생성 지원.
  트리거: "pkm" 키워드 포함 시, "노트 작성/추가/편집" 요청 시, "저널에 기록" 요청 시,
  PR URL/번호 언급 + 문서화 요청 시, "vault에서 찾아줘" 검색 요청 시,
  "책 추가", "영화 추가", "book", "movie", "읽은 책", "본 영화" 등 도서/영화 노트 생성 요청 시.
---

# PKM Skill - Obsidian Vault 관리

## Vault 경로

> [!CRITICAL] **절대 경로 - 반드시 준수**
> - **Vault 경로**: `/Users/casper/pkm` (소문자 pkm)
> - 다른 경로 사용 금지: `~/Library/Mobile Documents/...`, `iCloud~md~obsidian`, `SecondBrain` 등
> - 모든 파일 작업은 반드시 `/Users/casper/pkm` 하위에서만 수행

## obsidian CLI 사용 규칙

모든 vault 문서 조회/작성/편집은 `obsidian` CLI를 통해 수행한다. Obsidian 앱이 실행 중이어야 한다.

```bash
# path는 vault root 기준 상대 경로 사용
obsidian read path="007 inbox/파일명.md"
obsidian create name="파일명" path="007 inbox/파일명.md" content="..." silent
obsidian append path="007 inbox/파일명.md" content="추가할 내용"

# Obsidian에 여러 vault가 열려 있는 경우 vault 명시
obsidian vault="pkm" read path="007 inbox/파일명.md"
```

**핵심 규칙**:
- `path`는 항상 vault root 기준 상대 경로 (절대 경로 사용 금지)
- `silent` 플래그: 작업 후 파일이 Obsidian에서 열리지 않게 함
- 멀티라인 content는 bash 변수로 준비 후 전달

**멀티라인 content 작성 패턴**:
```bash
CONTENT=$(cat << 'EOF'
---
created: 2026-03-01 12:00:00
modified: 2026-03-01 12:00:00
tags:
  - work
---

# 노트 제목

내용
EOF
)
obsidian create name="파일명" path="007 inbox/파일명.md" content="$CONTENT" silent
```

---

## 참조 규칙

> [!IMPORTANT] **작업 시작 전 vault 규칙 파일을 반드시 읽을 것**
>
> Vault의 문서 컨벤션, frontmatter, 태그 체계 등은 아래 파일들에 정의되어 있다.
> SKILL.md에서는 중복을 피하고, 아래 파일들을 single source of truth로 참조한다.

| 규칙 | 파일 경로 |
|------|-----------|
| 디렉토리 구조, 파일 생성 위치, 파일명 규칙 | `/Users/casper/pkm/CLAUDE.md` |
| Frontmatter 필수/선택 필드 | `/Users/casper/pkm/.claude/rules/frontmatter.md` |
| 태그 체계 (기본 태그, 주제 태그, 허용 목록) | `/Users/casper/pkm/.claude/rules/tag.md` |
| 문서 구조, 마크다운 스타일, 네이밍 규칙 | `/Users/casper/pkm/.claude/rules/writing-guide.md` |
| 업무 문서 작성 절차, 저널 루틴 | `/Users/casper/pkm/.claude/rules/workflow.md` |
| 인물 문서 구조, 참조 방법 | `/Users/casper/pkm/.claude/rules/person.md` |
| 학습 기록 프로세스 | `/Users/casper/pkm/.claude/rules/learning.md` |

**작업 전 프로세스**:
1. 작업 유형에 해당하는 규칙 파일을 `obsidian read path="..."` 또는 `Read`로 읽기
2. 해당 규칙에 맞춰 작업 수행
3. 작업 완료 후 학습 기록 프로세스 수행 (`learning.md` 참고)

---

## 지원 기능

| 기능 | 트리거 예시 |
|------|-------------|
| 노트 생성 | "pkm에 노트 추가", "work 노트 만들어줘" |
| 노트 편집 | "pkm 노트 수정", "[[노트명]]에 내용 추가" |
| 노트 검색 | "vault에서 찾아줘", "pkm 검색" |
| Daily Journal | "저널에 기록", "오늘 일지에 추가" |
| PR 문서화 | "PR #123 문서화", PR URL + "정리해줘" |
| 책/영화 노트 | "영화 추가", "책 노트 만들어줘", "movie 추가", "본 영화 기록" |

---

## 공통 규칙: frontmatter 시간 기입

`created` / `modified` 필드에 시간을 기입할 때는 반드시 `Bash` 도구로 현재 시간을 확인한 후 사용한다. 추측하거나 임의 값을 넣지 않는다.

```bash
date '+%Y-%m-%d %H:%M:%S'
```

- **노트 생성 시**: `created` = `modified` = 현재 시간 → content에 포함하여 `obsidian create`
- **노트 편집 시**: `modified`만 현재 시간으로 갱신:
  ```bash
  obsidian property:set name="modified" value="YYYY-MM-DD HH:mm:ss" path="경로/파일명.md"
  ```

---

## 1. 노트 생성

1. `frontmatter.md`, `tag.md` 규칙에 맞춰 frontmatter 작성
2. `writing-guide.md` 구조에 맞춰 본문 작성
3. 파일 위치: `007 inbox/` (vault 상대 경로)
4. 파일명: 한글 자연어, 특수문자(`/\:*?"<>|#`) → `-` 대체, 최대 100자

```bash
# 현재 시간 확인
NOW=$(date '+%Y-%m-%d %H:%M:%S')

# 멀티라인 content 준비 후 노트 생성
CONTENT=$(cat << EOF
---
created: $NOW
modified: $NOW
tags:
  - [태그]
---

# 노트 제목

내용
EOF
)
obsidian create name="파일명" path="007 inbox/파일명.md" content="$CONTENT" silent
```

---

## 2. 노트 편집

1. `obsidian read path="..."` 또는 `obsidian read file="파일명"`으로 기존 내용 확인
2. 수정 방법 선택:

| 수정 유형 | 사용 방법 |
|-----------|-----------|
| 내용 추가 (끝에) | `obsidian append path="..." content="추가할 내용"` |
| 내용 추가 (앞에) | `obsidian prepend path="..." content="추가할 내용"` |
| 속성 값 변경 | `obsidian property:set name="속성명" value="값" path="..."` |
| 특정 섹션 수정 | `obsidian read`로 읽은 뒤 `Edit` 도구로 정확한 위치 수정 |

3. 기존 내용 보존, 중복 방지
4. `modified` 시간 갱신:
   ```bash
   obsidian property:set name="modified" value="$(date '+%Y-%m-%d %H:%M:%S')" path="경로/파일명.md"
   ```

---

## 3. 노트 검색

```bash
# 텍스트 검색 (파일 목록)
obsidian search query="검색어" limit=10

# 매칭 라인 컨텍스트 포함 검색
obsidian search:context query="검색어" limit=10

# 특정 폴더 내 검색
obsidian search query="검색어" path="003 resources" limit=10

# 폴더 내 전체 파일 목록
obsidian files folder="007 inbox"

# 태그로 검색
obsidian tag name="태그명" verbose

# 최근 열린 파일
obsidian recents
```

---

## 4. Daily Journal 관리

### 위치

**절대 경로**: `/Users/casper/pkm/005 journals/YYYY/YYYY-MM-DD.md`

### 백링크 추가 프로세스

1. **날짜 및 시간대 판단**:
   - 00:00~05:59 (새벽) → **전날 날짜**의 Evening 섹션에 기록 (아직 안 잔 것으로 간주)
   - 06:00~11:59 → 당일 Morning
   - 12:00~17:59 → 당일 Afternoon
   - 18:00~23:59 → 당일 Evening

2. **저널 파일 읽기**:
   ```bash
   obsidian daily:read         # 당일 (06:00 이후)
   obsidian read path="005 journals/YYYY/YYYY-MM-DD.md"  # 전날 (새벽 시간대)
   ```

3. **시간대 섹션에 백링크 삽입** — `obsidian daily:append` / `obsidian append` 사용 금지.
   반드시 `Read` 도구로 파일을 읽은 뒤 `Edit` 도구로 해당 섹션의 마지막 항목 바로 뒤에 삽입한다.
   ```
   ### Afternoon          ← 현재 시간이 12:00~17:59이면 이 섹션
   - 기존 항목
   - [[새 노트]]          ← 여기에 삽입
   ### Evening
   ```

4. 파일 없으면 `writing-guide.md`의 일간 저널 구조 참고하여 생성:
   ```bash
   CONTENT=$(cat << 'EOF'
   저널 초기 구조
   EOF
   )
   obsidian create name="YYYY-MM-DD" path="005 journals/YYYY/YYYY-MM-DD.md" content="$CONTENT" silent
   ```

5. 중복 체크: `Read`로 읽은 내용에 이미 동일 백링크가 있으면 스킵

---

## 5. PR 문서화

GitHub PR을 work 노트로 변환.

### PR 정보 수집

**URL 제공 시**: `gh pr view {url}` 사용

**번호만 제공 시**: 아래 repo 순차 검색
1. `https://github.kakaocorp.com/kjk/goomba-hub`
2. `https://github.kakaocorp.com/kjk/flutter_epub_viewer`
3. `https://github.kakaocorp.com/kjk/pluto_grid`
4. `https://github.kakaocorp.com/kjk/flutter_ocr`

중복 시 사용자에게 선택 요청.

### PR Work 노트 구조

```markdown
---
created: YYYY-MM-DD HH:mm:ss
modified: YYYY-MM-DD HH:mm:ss
date: YYYY-MM-DD
tags:
  - work
  - [PR 타입 기반 주제 태그]
pr_url: [URL]
repository: [repo-name]
---

>[!summary]
>- [핵심 변경사항 1~3개]

## 개요
- **목적**: [목적]
- **변경 범위**: [모듈/컴포넌트]
- **상태**: [OPEN/MERGED/CLOSED]

## 변경사항

### 주요 구현
- **[파일/모듈]**: [변경 내용]

### 아키텍처
```mermaid
[필요시 다이어그램]
```

## 기술적 의사결정

| 선택지 | 선택 이유 | Trade-off |
|--------|----------|-----------|

## 테스트
- **검증 결과**: [Pass/Fail]

## 후속 작업
- [ ] [개선/확장 아이디어]

## 참고
- **PR**: [URL]
- **Related Issues**: [#issue]
```

### 노트 생성

PR 내용을 구성한 뒤 obsidian-cli로 생성:

**파일명 규칙**: `PR{번호} - {제목에서 type prefix 제거한 설명}`
- PR 번호 앞 `#` 사용 금지: `PR1748 - ...` (❌ `PR#1748`)
- `feat:`, `fix:` 등 type prefix 제거: 태그로 표현하므로 파일명에는 불필요
- 예시: `PR1748 - appcast PR 머지 시 Goomba-Hub-Appcast-upload 자동 트리거`

```bash
NOW=$(date '+%Y-%m-%d %H:%M:%S')
CONTENT=$(cat << 'EOF'
위 PR Work 노트 구조에 맞게 채운 내용
EOF
)
obsidian create name="PR{번호} - {설명}" path="007 inbox/PR{번호} - {설명}.md" content="$CONTENT" silent
```

### PR 타입 → 주제 태그 매핑

| PR 타입 | 주제 태그 |
|---------|-----------|
| `feat:`, `feature:` | feature |
| `fix:` | fix |
| `refactor:` | refactor |
| `docs:` | docs |
| `chore:`, `build:`, `ci:`, `test:` | chore |
| "troubleshoot", "debug" 포함 | troubleshooting |
| "plan", "design" 포함 | planning |
| 판단 불가 | feature (기본) |

---

## 6. 책/영화 노트 생성

### 제목 확인

1. 사용자 입력에서 제목을 추출할 수 있으면 그대로 사용
   - 예: "오펜하이머 영화 추가해줘" → 제목: `오펜하이머`
   - 예: "프로젝트 헤일메리 책 노트 만들어줘" → 제목: `프로젝트 헤일메리`
2. 제목을 알 수 없으면 `AskUserQuestion`으로 제목 확인

### 영화 노트

**파일 위치**: `003 resources/movies/{제목}.md`

**중복 확인**: `obsidian search query="제목" path="003 resources/movies" limit=1`로 검색하여 동일 제목 파일이 이미 존재하면 사용자에게 알리고 중단

**Frontmatter**:

```yaml
---
created: YYYY-MM-DD HH:mm:ss
modified: YYYY-MM-DD HH:mm:ss
tags:
  - movie
watch_date:
status: TO WATCH
title: "제목"
genre: []
director: []
actor: []
release_year:
cover:
rating: ⭐️
comment:
---
```

**TMDB 자동 검색** (메타데이터 자동 채우기):

제목이 확정되면 TMDB API로 영화 정보를 검색하여 frontmatter를 자동으로 채운다.

> [!IMPORTANT] API key는 환경변수 `$TMDB_API_KEY`를 사용한다. 절대 하드코딩하지 않는다.
> `$TMDB_API_KEY`가 정의되어 있지 않으면 TMDB 검색을 **건너뛰고** cover를 비워둔 채 노트를 생성한다.

```bash
# 영화 검색
curl -s "https://api.themoviedb.org/3/search/movie?api_key={TMDB_API_KEY}&query={제목}&language=ko-KR"

# TV 시리즈인 경우 (드라마, 시리즈물)
curl -s "https://api.themoviedb.org/3/search/tv?api_key={TMDB_API_KEY}&query={제목}&language=ko-KR"
```

- 검색 결과에서 첫 번째 결과 사용
- `poster_path` → `cover: https://image.tmdb.org/t/p/w500/{poster_path}`
- `release_date` → `release_year` (연도만 추출)
- `genre_ids` → `genre` (장르 ID를 한글 장르명으로 변환)
- 한글 제목으로 검색 실패 시 영어 원제(`original_title`)로 재시도
- 감독/출연진은 TMDB credits API로 추가 조회 가능:
  ```bash
  curl -s "https://api.themoviedb.org/3/movie/{movie_id}/credits?api_key={TMDB_API_KEY}&language=ko-KR"
  ```
  - `crew`에서 `job: "Director"` → `director`
  - `cast` 상위 3~5명 → `actor`

**TMDB 장르 ID → 한글 매핑**:

| ID | 장르 | ID | 장르 |
|----|------|----|------|
| 28 | 액션 | 12 | 모험 |
| 16 | 애니메이션 | 35 | 코미디 |
| 80 | 범죄 | 99 | 다큐멘터리 |
| 18 | 드라마 | 10751 | 가족 |
| 14 | 판타지 | 36 | 역사 |
| 27 | 공포 | 10402 | 음악 |
| 9648 | 미스터리 | 10749 | 로맨스 |
| 878 | SF | 53 | 스릴러 |
| 10752 | 전쟁 | 37 | 서부 |
| 10770 | TV 영화 | | |

**노트 생성**:

```bash
NOW=$(date '+%Y-%m-%d %H:%M:%S')
CONTENT=$(cat << 'EOF'
frontmatter + 본문 내용
EOF
)
obsidian create name="제목" path="003 resources/movies/제목.md" content="$CONTENT" silent
```

**본문 구조**:

```markdown
## 내용 요약

## 느낀 점
```

### 책 노트

**파일 위치**: `003 resources/books/{제목}.md`

**중복 확인**: `obsidian search query="제목" path="003 resources/books" limit=1`로 검색하여 동일 제목 파일이 이미 존재하면 사용자에게 알리고 중단

**Frontmatter**:

```yaml
---
created: YYYY-MM-DD HH:mm:ss
modified: YYYY-MM-DD HH:mm:ss
tags:
  - personal
  - book
start:
finish:
status: TO READ
title: "제목"
genre:
author:
isbn:
cover:
rating: ⭐️
comment:
---
```

- 사용자가 저자, 장르 등 추가 정보를 제공하면 함께 기입
- cover는 웹 검색으로 표지 이미지 URL을 찾아 채울 수 있음 (선택적)

**노트 생성**:

```bash
NOW=$(date '+%Y-%m-%d %H:%M:%S')
CONTENT=$(cat << 'EOF'
frontmatter + 본문 내용
EOF
)
obsidian create name="제목" path="003 resources/books/제목.md" content="$CONTENT" silent
```

**본문 구조**:

```markdown
## 내용 요약

## 느낀 점
```

---

## 에러 처리

| 상황 | 처리 |
|------|------|
| 파일 미존재 | `obsidian create`로 새로 생성 |
| 섹션 미존재 | `obsidian append`로 섹션 추가 |
| 중복 백링크 | `obsidian read`로 확인 후 이미 있으면 스킵 |
| PR 미발견 | 에러 메시지 출력 |

## 의존성

- `obsidian` CLI (문서 조회/작성/편집 — Obsidian 앱 실행 중이어야 함)
- `Read` 도구 (vault 규칙 파일 읽기용)
- `Edit` 도구 (특정 섹션 인플레이스 수정 시 보조)
- GitHub CLI (`gh`) — PR 문서화 시
