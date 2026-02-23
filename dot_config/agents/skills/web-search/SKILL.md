---
name: web-search
description: >
  DuckDuckGo 기반 웹 검색 스킬. 텍스트, 뉴스, 이미지, 비디오 검색을 지원하며
  지역/기간 필터와 구조화된 출력(JSON/Markdown)을 제공한다.
  빌트인 WebSearch 대비 뉴스/이미지/비디오 전용 검색, 지역·기간 필터, 필드 선택 토큰 절약이 가능하다.
  트리거: 사용자가 "웹 검색", "뉴스 검색", "이미지 검색", "비디오 검색", "web search",
  "DuckDuckGo", "검색해줘", "찾아줘", "국내 커뮤니티", "국내 반응", "국내 여론",
  "커뮤니티 반응", "한국 커뮤니티 검색", "국내에서 찾아줘" 등을 언급하거나,
  특정 지역/기간 필터가 필요한 검색 요청 시.
  빌트인 WebSearch로 충분하지 않은 고급 검색(타입별 검색, 필드 선택, 지역 필터 등)이 필요할 때 사용한다.
  또한 WebFetch가 차단하는 도메인(Reddit 등)의 웹 페이지를 직접 fetch할 수 있다.
  "페이지 읽어줘", "URL 내용", "Reddit 글 가져와", "fetch" 등의 요청에도 사용한다.
---

# Web Search

빌트인 `WebSearch`와의 차이점:
- 뉴스, 이미지, 비디오 전용 검색 타입
- 지역(region) 및 기간(timelimit) 필터
- JSON 또는 Markdown 구조화 출력
- 필드 선택으로 토큰 절약

## 페이지 Fetch

빌트인 `WebFetch`가 차단하는 도메인(Reddit 등)의 페이지를 직접 가져온다.
Reddit URL은 자동으로 JSON API를 사용하여 게시글 + 댓글을 구조화된 형태로 반환한다.

```bash
FETCH="$SKILL_DIR/scripts/fetch.py"

# Reddit 게시글 읽기 (Markdown 출력)
python3 "$FETCH" "https://www.reddit.com/r/ClaudeCode/comments/..." -f md

# Reddit 댓글 최대 20개
python3 "$FETCH" "https://www.reddit.com/r/..." -c 20

# 일반 웹 페이지 읽기
python3 "$FETCH" "https://example.com/article" -f md

# JSON 출력
python3 "$FETCH" "https://www.reddit.com/r/..." -f json

# 출력 길이 제한 (토큰 절약)
python3 "$FETCH" "https://example.com" --max-length 5000
```

### Fetch 파라미터

| 파라미터 | 단축 | 기본값 | 설명 |
|---------|------|-------|------|
| `url` (위치) | — | 필수 | 가져올 URL |
| `--format` | `-f` | `md` | 출력 형식: json, md |
| `--max-comments` | `-c` | `10` | Reddit 최대 댓글 수 |
| `--timeout` | — | `15` | HTTP 타임아웃(초) |
| `--max-length` | — | `0` | 최대 출력 글자 수 (0=무제한) |

## 검색 사용법

스크립트 경로: 이 SKILL.md와 같은 디렉토리의 `scripts/search.py`.
실행 시 이 파일의 절대 경로를 기준으로 `SCRIPT` 변수를 설정한다.

```bash
# SKILL_DIR: 이 SKILL.md가 위치한 디렉토리의 절대 경로로 치환
SCRIPT="$SKILL_DIR/scripts/search.py"

# 텍스트 검색
python3 "$SCRIPT" "검색어" -n 5

# Markdown 출력 (Claude가 바로 읽기 좋은 형태)
python3 "$SCRIPT" "검색어" -f md -n 5

# 한국 뉴스 (최근 1주일)
python3 "$SCRIPT" "AI 뉴스" -t news -r kr-kr -p w -f md

# 비디오 검색
python3 "$SCRIPT" "python tutorial" -t videos -n 5

# 이미지 검색 (특정 필드만)
python3 "$SCRIPT" "web design" -t images --fields title,image -n 5
```

## 검색 타입별 반환 필드

| 타입 | 주요 필드 |
|------|----------|
| text | title, href, body |
| news | title, url, body, source, date |
| images | title, image, url, width, height |
| videos | title, content(URL), description, duration, publisher |

## 국내 커뮤니티 검색

국내 주요 커뮤니티를 대상으로 `site:` 검색을 수행하고 결과를 종합한다. `--sites` 옵션으로 프리셋 또는 직접 도메인을 지정한다.

### 프리셋

| 프리셋 | 용도 | 포함 사이트 |
|--------|------|------------|
| `kr` | 종합 커뮤니티 | 클리앙, 에펨코리아, 더쿠, 디시인사이드, 루리웹, 뽐뿌, 오늘의유머, 82cook |
| `kr-dev` | IT/개발 | GeekNews, OKKY, 디스콰이엇, 커리어리 |
| `kr-opinion` | 시사/여론 | 클리앙, 에펨코리아, 더쿠, 디시인사이드, 82cook, 오늘의유머, MLB파크, SLR클럽 |
| `kr-career` | 직장/커리어 | 블라인드, 커리어리, OKKY |
| `kr-auto` | 자동차 | 보배드림 |
| `kr-game` | 게임 | 인벤, 루리웹 |

### 사용 예시

```bash
SCRIPT="$SKILL_DIR/scripts/search.py"

# 종합 커뮤니티 검색
python3 "$SCRIPT" "Claude Code" --sites kr -f md

# IT/개발 커뮤니티 검색
python3 "$SCRIPT" "React 19" --sites kr-dev -f md

# 프리셋 결합 (+)
python3 "$SCRIPT" "이직" --sites kr-dev+kr-career -f md

# 직접 도메인 지정 (쉼표 구분)
python3 "$SCRIPT" "AI" --sites clien.net,theqoo.net -f md

# 뉴스 타입 + 커뮤니티
python3 "$SCRIPT" "Claude" --sites kr-dev -t news -f md

# 사이트별 결과 수 조정
python3 "$SCRIPT" "GPT" --sites kr --per-site 5 -n 20 -f md

# 프리셋 목록 확인
python3 "$SCRIPT" "" --list-presets
```

### 트리거 → 프리셋 매핑

| 사용자 요청 | 추천 프리셋 |
|------------|-----------|
| "국내 커뮤니티에서 찾아줘" | `kr` |
| "국내 반응", "국내 여론" | `kr-opinion` |
| "개발자 반응 (국내)" | `kr-dev` |
| "직장인 반응", "블라인드에서" | `kr-career` |
| "자동차 커뮤니티" | `kr-auto` |
| "게임 커뮤니티" | `kr-game` |

### 국내 커뮤니티 워크플로우

```
1. 멀티사이트 검색으로 커뮤니티별 관련 글 확보
   python3 "$SCRIPT" "주제" --sites kr -f md
2. 주요 글을 fetch.py 또는 WebFetch로 상세 내용 확보
   python3 "$FETCH" "https://clien.net/..." -f md
3. 커뮤니티별 반응을 종합하여 사용자에게 보고
```

## 출력 옵션

### Markdown 출력 (`-f md`)

각 타입에 맞는 읽기 좋은 포맷으로 출력한다. Claude가 결과를 바로 분석할 수 있어 **기본적으로 `-f md`를 권장**한다.

### 필드 선택 (`--fields`)

필요한 필드만 출력하여 토큰을 절약한다:

```bash
# URL과 제목만
python3 "$SCRIPT" "검색어" --fields title,href -n 10

# 뉴스 제목과 날짜만
python3 "$SCRIPT" "AI" -t news --fields title,date -f md
```

### 토큰 절약 팁

1. `-f md`로 JSON 오버헤드 제거
2. `--fields`로 불필요한 필드 제외
3. `-n`으로 결과 수 제한 (기본 10)

## 워크플로우

### (A) 검색 → Fetch 심층 분석

```
1. 검색으로 관련 URL 목록 확보
   python3 "$SCRIPT" "주제" -f md -n 5
2. WebFetch 차단 도메인(Reddit 등)은 fetch.py로, 그 외는 WebFetch로 상세 내용 확보
   python3 "$FETCH" "https://www.reddit.com/r/..." -f md
3. 결과를 종합하여 사용자에게 보고
```

### 결과 보고 규칙

검색/fetch 결과를 사용자에게 요약할 때 **반드시 출처 URL을 포함**한다.

#### 개별 결과 보고

```markdown
### 제목 (score: 123)
https://www.reddit.com/r/.../comments/...
- 요약 내용...
```

#### 종합 요약 보고

여러 검색 결과를 종합하여 요약할 때, **각 내용의 근거가 된 출처를 인라인 링크 또는 각주로 반드시 표기**한다.
출처 없는 요약은 금지한다.

```markdown
## 요약 제목

### 1. 주제 A

내용 요약... ([출처1 제목](URL1), [출처2 제목](URL2))

### 2. 주제 B

내용 요약... ([출처3 제목](URL3))

---

### 출처 목록
- [출처1 제목](URL1)
- [출처2 제목](URL2)
- [출처3 제목](URL3)
```

**규칙:**
- 요약 본문 속 각 주장/사실에 해당 출처를 인라인 링크로 달 것
- 보고서 하단에 전체 출처 목록을 별도 섹션으로 정리할 것
- 동일 내용에 여러 출처가 있으면 대표 1~2개만 인라인에 넣고, 나머지는 출처 목록에 포함

### (B) 딥 리서치 패턴

```
1. 넓은 검색으로 전체 윤곽 파악
   python3 "$SCRIPT" "broad topic" -f md -n 10
2. 결과에서 핵심 키워드 추출
3. 좁은 재검색으로 심화
   python3 "$SCRIPT" "specific subtopic" -f md -n 5
4. news/videos로 최신 동향 보완
   python3 "$SCRIPT" "topic" -t news -p w -f md -n 5
```

### (D) 국내 커뮤니티 분석

```
1. 멀티사이트 검색으로 전체 윤곽 파악
   python3 "$SCRIPT" "주제" --sites kr -f md
2. IT 주제라면 개발 커뮤니티도 병행
   python3 "$SCRIPT" "주제" --sites kr-dev -f md
3. 주요 글을 fetch로 상세 확인
   python3 "$FETCH" "https://clien.net/..." -f md
4. 커뮤니티별 반응/여론을 종합 보고 (출처 포함)
```

### (C) 검색어 최적화

- **기술 문서**: 영어로 검색 (더 넓은 결과)
- **로컬 정보**: 한국어 + `-r kr-kr`
- **검색 연산자**: `site:github.com`, `filetype:pdf`, `"exact phrase"`, `-exclude`

## 파라미터 레퍼런스

| 파라미터 | 단축 | 기본값 | 설명 |
|---------|------|-------|------|
| `query` (위치) | — | 필수 | 검색어 |
| `--type` | `-t` | `text` | text, news, images, videos |
| `--max-results` | `-n` | `10` | 최대 결과 수 |
| `--region` | `-r` | `wt-wt` | 지역 코드 (예: kr-kr, us-en) |
| `--format` | `-f` | `json` | 출력 형식: json, md |
| `--fields` | — | 전체 | 출력 필드 (콤마 구분) |
| `--timelimit` | `-p` | None | 기간: d(일), w(주), m(월), y(년) |
| `--safesearch` | `-s` | `moderate` | on, moderate, off |
| `--timeout` | — | `10` | HTTP 타임아웃(초) |
| `--page` | — | `1` | 결과 페이지 |
| `--sites` | — | None | 프리셋 이름 또는 쉼표 구분 도메인 (`+`로 결합) |
| `--per-site` | — | `3` | 사이트별 최대 결과 수 |
| `--site-delay` | — | `1.0` | 사이트 간 딜레이(초) |
| `--list-presets` | — | — | 프리셋 목록 출력 후 종료 |

<!-- 원본 참고: https://github.com/bear2u/my-skills/tree/master/skills/web-search -->
