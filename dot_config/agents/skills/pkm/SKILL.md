---
name: pkm
description: |
  Obsidian PKM vault 관리 스킬. 노트 생성/편집/검색, Daily Journal 관리, PR 문서화 지원.
  트리거: "pkm" 키워드 포함 시, "노트 작성/추가/편집" 요청 시, "저널에 기록" 요청 시,
  PR URL/번호 언급 + 문서화 요청 시, "vault에서 찾아줘" 검색 요청 시.
---

# PKM Skill - Obsidian Vault 관리

## Vault 정보

> [!CRITICAL] **절대 경로 - 반드시 준수**
> - **Vault 경로**: `/Users/casper/pkm` (소문자 pkm)
> - 다른 경로 사용 금지: `~/Library/Mobile Documents/...`, `iCloud~md~obsidian`, `SecondBrain` 등
> - 모든 파일 작업은 반드시 `/Users/casper/pkm` 하위에서만 수행

| 항목 | 절대 경로 |
|------|-----------|
| Vault Root | `/Users/casper/pkm` |
| 새 파일 | `/Users/casper/pkm/007 inbox/` |
| 저널 | `/Users/casper/pkm/005 journals/YYYY/YYYY-MM-DD.md` |
| 템플릿 | `/Users/casper/pkm/003 resources/templates/` |

## 지원 기능

| 기능 | 트리거 예시 |
|------|-------------|
| 노트 생성 | "pkm에 노트 추가", "work 노트 만들어줘" |
| 노트 편집 | "pkm 노트 수정", "[[노트명]]에 내용 추가" |
| 노트 검색 | "vault에서 찾아줘", "pkm 검색" |
| Daily Journal | "저널에 기록", "오늘 일지에 추가" |
| PR 문서화 | "PR #123 문서화", PR URL + "정리해줘" |

---

## 1. 노트 생성

### 템플릿

**work** (업무 문서):
```yaml
---
created: YYYY-MM-DD HH:mm:ss
modified: YYYY-MM-DD HH:mm:ss
date: YYYY-MM-DD
tags:
  - work
category: [category]
---
```

**personal** (개인 문서):
```yaml
---
created: YYYY-MM-DD HH:mm:ss
modified: YYYY-MM-DD HH:mm:ss
date: YYYY-MM-DD
tags:
  - personal
category: [category]
---
```

### Category 값

**Work**: feature, fix, refactor, docs, chore, meeting, 1on1, troubleshooting, planning, retro, idea, resource, setup, okr

**Personal**: gather, study, finance, health, travel, hobby, dev, idea, resource, setup

### 파일명 규칙

- **한글 자연어 형식**, 공백 허용
- 특수문자(`/\:*?"<>|`) → `-` 대체
- 최대 100자
- 예: `로컬 소설 Auto 분할 작업 산출물 생성 기능 구현.md`

### 문서 구조

```markdown
>[!summary] 
>- 요약 1
>- 요약 2

# 목적

[작업 목적/배경]

# 작업 내용

[상세 내용]

# 참고

- [링크](URL)
- [[관련 노트]]
```

---

## 2. 노트 편집

1. `obsidian_get_file_contents` 또는 `Read`로 기존 내용 확인
2. 수정할 위치 파악 (섹션, frontmatter 등)
3. `Edit` 도구로 정확한 위치에 수정
4. 기존 내용 보존, 중복 방지

---

## 3. 노트 검색

**MCP 도구 우선 사용**:
- `obsidian_simple_search`: 텍스트 검색
- `obsidian_complex_search`: JsonLogic 쿼리 (태그, 경로 필터)
- `obsidian_list_files_in_dir`: 특정 폴더 파일 목록

**검색 팁**:
- 태그 검색: `{"glob": ["*.md", {"var": "path"}]}` + frontmatter 확인
- 최근 수정: `obsidian_get_recent_changes`

---

## 4. Daily Journal 관리

### 위치 및 구조

**절대 경로**: `/Users/casper/pkm/005 journals/YYYY/YYYY-MM-DD.md`

**시간대별 섹션**:
- Morning: 06:00~11:59
- Afternoon: 12:00~17:59
- Evening: 18:00~23:59

### 백링크 추가 프로세스

**중요**: `obsidian_patch_content` / `obsidian_append_content` 사용 금지

1. `Read`로 journal 파일 읽기
2. 파일 없으면 생성:
   ```markdown
   ---
   date: YYYY-MM-DD
   tags:
     - daily
   ---
   
   ## Morning
   
   ## Afternoon
   
   ## Evening
   ```
3. 시간대 섹션 찾기 (없으면 추가)
4. `Edit`로 섹션 끝에 `- [[노트 제목]]` 또는 메모 추가
5. 중복 체크, 기존 내용 보존

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
category: [PR 타입 기반]
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

### Category 판단 (PR)

| PR 타입 | Category |
|---------|----------|
| `feat:`, `feature:` | feature |
| `fix:` | fix |
| `refactor:` | refactor |
| `docs:` | docs |
| `chore:`, `build:`, `ci:`, `test:` | chore |
| "troubleshoot", "debug" 포함 | troubleshooting |
| "plan", "design" 포함 | planning |
| 판단 불가 | feature (기본) |

---

## 공통 규칙

### Frontmatter 필수 필드

- `created`: YYYY-MM-DD HH:mm:ss
- `modified`: YYYY-MM-DD HH:mm:ss
- `date`: YYYY-MM-DD
- `tags`: 배열 (work 또는 personal)
- `category`: 문서 분류

### 마크다운 스타일

- **위키링크**: `[[파일명]]`, `[[파일명|별칭]]`, `[[파일명#섹션]]`
- **Callout**: `>[!summary]`, `>[!info]`, `>[!tip]`, `>[!warning]`
- **임베드**: `![[파일명]]`

### 에러 처리

| 상황 | 처리 |
|------|------|
| 파일 미존재 | 새로 생성 |
| 섹션 미존재 | 섹션 추가 |
| 중복 백링크 | 스킵 |
| PR 미발견 | 에러 메시지 출력 |

## 의존성

- Obsidian MCP 도구 (`obsidian_*`)
- Read/Edit 도구 (파일 직접 조작)
- GitHub CLI (`gh`) - PR 문서화 시
