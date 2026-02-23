---
name: backlog-summary
description: >
  Backlog 이슈를 카테고리·상태별로 조회하여 한글 요약 보고서를 생성하는 오케스트레이션 스킬.
  이슈별 난이도·중요도·해결 방법 예상을 포함하며, 필요한 이슈는 코드 레벨 심화 분석까지 수행한다.
  결과를 PKM inbox에 마크다운 문서로 저장하고 Slack DM으로 완료를 알린다.
  트리거: "backlog 요약", "backlog summary", "백로그 요약", "백로그 이슈 요약",
  "이슈 요약해줘", "백로그 정리", "이슈 정리해줘" 등.
---

# Backlog Summary

Backlog 이슈를 조회·분석·요약하여 PKM 문서 + Slack 알림으로 전달하는 스킬.

## 의존성

| 스킬/도구 | 용도 |
|-----------|------|
| backlog 스킬 | Backlog API 설정 (`~/.claude/skills/backlog/config.json`) |
| pkm 스킬 | inbox 경로 (`/Users/casper/pkm/007 inbox/`) |
| Slack MCP | DM 발송 (`slack_send_message`) |

## 워크플로우 개요

```
1. 사용자 입력 수집 (카테고리, 상태)
2. Backlog API로 이슈 목록 조회
3. 분석 대상 이슈 선택 (10건 초과 시)
4. 1차 분석 (이슈별 병렬) — 요약, 난이도, 중요도, 해결 방법 예상
5. 2차 심화 분석 (필요한 이슈만 병렬) — 코드 레벨 원인·해결책
6. PKM inbox에 요약 문서 생성
7. Slack DM으로 완료 알림
```

---

## 1단계: 사용자 입력 수집

`AskUserQuestion`으로 두 가지를 질문한다.

### 이슈 카테고리

- 선택지: `app`, `web`
- 기본값: `app`
- `multiSelect: true` (복수 선택 가능)

### 이슈 상태

- 선택지: `Open`, `Ready`, `In Progress`, `Resolved`, `Stage-Released`, `Stage-Checked`, `Real-Released`, `Closed`
- 기본값: `Open`
- `multiSelect: true` (복수 선택 가능)

---

## 2단계: Backlog API로 이슈 목록 조회

### 설정 읽기

`~/.claude/skills/backlog/config.json`에서 `spaceKey`, `apiKey`, `domain`, `projectKey`를 읽는다.

### 카테고리·상태 ID 매핑

이름→ID 매핑이 필요하다. 프로젝트의 카테고리·상태 목록을 API로 조회한다.

```bash
# 카테고리 목록
curl -s "https://{spaceKey}.{domain}/api/v2/projects/{projectKey}/categories?apiKey={apiKey}"

# 상태 목록
curl -s "https://{spaceKey}.{domain}/api/v2/projects/{projectKey}/statuses?apiKey={apiKey}"
```

응답에서 `name`이 사용자가 선택한 값과 일치하는 항목의 `id`를 추출한다.

### 이슈 조회

```bash
curl -s "https://{spaceKey}.{domain}/api/v2/issues?apiKey={apiKey}&projectId[]={projectId}&categoryId[]={categoryId}&statusId[]={statusId}&count=100&order=desc"
```

- `count=100`으로 최대한 많이 가져온다
- 100건 초과 시 `offset`으로 페이징

---

## 3단계: 분석 대상 이슈 선택

조회된 이슈가 **10건 이하**이면 이 단계를 건너뛰고 전부 분석 대상으로 진행한다.

조회된 이슈가 **10건 초과**이면 사용자에게 분석할 이슈를 선택받는다.

### 이슈 목록 출력

먼저 조회된 전체 이슈를 번호 매긴 테이블로 출력한다. 일본어/영어 제목은 한글로 번역하여 표시한다.

```
조회 결과: 총 {N}건

| # | 이슈 키 | 제목 | 우선순위 | 담당자 |
|---|---------|------|----------|--------|
| 1 | CONTENTSHUB-973 | TSV 출력 시 본편 파일명 표시 변경 | Normal | hana |
| 2 | CONTENTSHUB-972 | 분할 화면 LOAD TSV 에러 (삭제 페이지 0 오판정) | Normal | hana |
| ... |
```

### AskUserQuestion으로 선택

`AskUserQuestion`을 사용하여 분석 대상을 선택받는다.

- `multiSelect: false`
- 첫 번째 옵션: **"모두 선택 (Recommended)"** — 전체 이슈를 분석 대상으로 진행
  - description: "조회된 {N}건 전부를 분석합니다"
- 두 번째 옵션: **"직접 선택"** — 사용자가 번호를 직접 입력
  - description: "위 목록에서 분석할 이슈 번호를 쉼표로 입력합니다 (예: 1,3,5,7)"

사용자가 **"직접 선택"** 또는 **Other**를 선택한 경우:
- 사용자가 입력한 번호(쉼표 구분)를 파싱하여 해당 이슈만 분석 대상으로 필터링
- 범위 입력도 지원: `1-5,8,10` → 1,2,3,4,5,8,10번 이슈

---

## 4단계: 1차 분석 (이슈별 병렬)

각 이슈에 대해 `Task` 도구로 병렬 서브에이전트를 생성한다. (`subagent_type: "general-purpose"`)

> **병렬 처리 규칙**: 이슈가 10건 이하이면 전부 병렬, 10건 초과이면 10건씩 배치로 나누어 처리.

각 서브에이전트가 분석할 항목:

| 항목 | 설명 |
|------|------|
| 이슈 키 | `CONTENTSHUB-1234` 형태 그대로 유지 |
| 이슈 제목 (한글) | 원본이 영어/일본어면 한글로 번역. 이미 한글이면 그대로 |
| 이슈 내용 요약 | description에서 **내용, 원인, 재현 방법, 기대 결과** 위주로 3~5줄 요약 |
| 난이도 | `간단` / `복잡` |
| 중요도 | Backlog의 priority를 기반으로 `높음` / `보통` / `낮음` |
| 해결 방법 예상 | 1~2줄로 예상되는 해결 접근법 |
| 심화 분석 필요 여부 | `true` / `false` — 코드 레벨 분석이 필요한지 판단 |

### 심화 분석 필요 판단 기준

- `간단`한 이슈 (설정 변경, 텍스트 수정, 단순 UI 조정 등) → `false`
- 아래 중 하나라도 해당하면 → `true`:
  - 원인이 불명확하거나 description에 충분한 정보가 없는 경우
  - 비즈니스 로직 변경이 필요한 경우
  - 여러 파일/모듈에 걸친 수정이 예상되는 경우
  - 성능, 메모리, 동시성 관련 이슈

---

## 5단계: 심화 분석 (이슈별 병렬)

4단계에서 `심화 분석 필요: true`인 이슈들만 대상으로 한다.

각 이슈에 대해 `Task` 도구로 병렬 서브에이전트를 생성한다. (`subagent_type: "general-purpose"`)

서브에이전트에게 전달할 정보:
- 이슈 키, 제목, description 전문
- 프로젝트 코드베이스 경로: `/Users/casper/Workspace/goomba-hub`

서브에이전트 수행 내용:
1. 이슈 내용에서 관련 키워드 추출 (파일명, 클래스명, 함수명, 에러 메시지 등)
2. `Grep`/`Glob`으로 코드베이스에서 관련 코드 탐색
3. 원인 분석 및 수정 방향 제시

각 서브에이전트 결과 형식:

```
## 심화 분석: {이슈 키}
- **관련 파일**: [파일 경로 목록]
- **원인 분석**: [코드 레벨 원인 설명]
- **수정 방향**: [구체적 수정 방법]
```

---

## 6단계: PKM inbox 문서 생성

### 파일 경로

`/Users/casper/pkm/007 inbox/YYYY-MM-DD 백로그 이슈 요약.md`

동일 이름 파일이 이미 존재하면 `(1)`, `(2)` 등 숫자를 붙인다:
- `2026-02-18 백로그 이슈 요약.md` (기존 존재)
- → `2026-02-18 백로그 이슈 요약 (1).md`

### 문서 구조

```markdown
---
created: YYYY-MM-DD HH:mm:ss
modified: YYYY-MM-DD HH:mm:ss
tags:
  - work
  - backlog-summary
---

> [!summary]
> - 조회 조건: 카테고리 [{선택된 카테고리}], 상태 [{선택된 상태}]
> - 총 {N}건 중 심화 분석 {M}건

## 이슈 요약

| # | 이슈 키 | 제목 | 난이도 | 중요도 | 심화 |
|---|---------|------|--------|--------|------|
| 1 | CONTENTSHUB-1234 | 이슈 제목 | 간단 | 높음 | - |
| 2 | CONTENTSHUB-1235 | 이슈 제목 | 복잡 | 보통 | ✅ |

## 이슈 상세

### CONTENTSHUB-1234: 이슈 제목

- **상태**: Open
- **담당자**: {assignee name}
- **내용 요약**: {3~5줄 요약}
- **해결 방법 예상**: {1~2줄}

### CONTENTSHUB-1235: 이슈 제목 (심화 분석 포함)

- **상태**: Open
- **담당자**: {assignee name}
- **내용 요약**: {3~5줄 요약}
- **해결 방법 예상**: {1~2줄}

#### 심화 분석

- **관련 파일**: [파일 경로 목록]
- **원인 분석**: [코드 레벨 원인]
- **수정 방향**: [구체적 수정 방법]
```

---

## 7단계: Slack DM 발송

환경변수 `$BACKLOG_SUMMARY_DM`에 DM 대상 사용자가 지정되어 있다.

1. `$BACKLOG_SUMMARY_DM` 값을 확인한다
2. 비어있으면 Slack 발송을 건너뛴다
3. 값이 있으면 `slack_send_message`로 DM을 보낸다

### 메시지 형식

```
📋 백로그 이슈 요약 완료

• 조회 조건: {카테고리}, {상태}
• 총 {N}건 (심화 분석 {M}건)
• 주요 이슈:
  - {이슈키}: {제목} ({난이도}/{중요도})
  - {이슈키}: {제목} ({난이도}/{중요도})
  - ... (최대 5건)

📄 문서: {파일명}
📁 위치: pkm inbox
```

- 주요 이슈는 중요도 높음 → 복잡 순으로 최대 5건 표시
- 전체 상세는 PKM 문서 참고 안내

---

## 에러 처리

| 상황 | 처리 |
|------|------|
| Backlog config 미설정 | backlog 스킬의 설정 안내 메시지 출력 |
| 조회 결과 0건 | "해당 조건의 이슈가 없습니다" 안내 후 종료 |
| `$BACKLOG_SUMMARY_DM` 미설정 | Slack 발송 건너뜀 (PKM 문서는 정상 생성) |
| API 호출 실패 | 에러 메시지와 함께 재시도 안내 |
