---
name: make-backlog-comment-jp
description: Backlog 이슈에 PR 주소와 변경사항 요약을 일본어+한국어 병기 코멘트로 남기는 스킬. 일본어 비즈니스 문체(ます체)로 3줄 요약을 먼저 작성하고, 구분선 아래에 한국어 요약을 병기한다. 트리거 - "backlog 코멘트 일본어", "백로그 코멘트 jp", "일본어 코멘트", "JP 코멘트", "make-backlog-comment-jp" 등. 일본인 팀원이 있는 프로젝트에서 PR 작업 내용을 Backlog에 기록할 때, 또는 사용자가 일본어 병기를 명시적으로 요청할 때 사용한다. 한국어만 필요하면 make-backlog-comment 스킬을 대신 사용한다.
---

# Make Backlog Comment (JP)

Backlog 이슈에 PR 주소와 변경사항 요약을 일본어+한국어 병기 코멘트로 남긴다.

## 사용법

```
/make-backlog-comment-jp CONTENTSHUB-1234
```

인자가 없으면 현재 브랜치의 PR 제목에서 이슈 키를 자동 추출한다.

## 워크플로우

### 1. Backlog 설정 로드

```bash
CONFIG="/Users/casper/.config/santaclaude/backlog/config.json"
SPACE_KEY=$(jq -r '.spaceKey' "$CONFIG")
DOMAIN=$(jq -r '.domain' "$CONFIG")
API_KEY=$(jq -r '.apiKey' "$CONFIG")
```

`apiKey`가 비어있으면 중단하고 `/backlog` 스킬로 설정하라고 안내한다.

### 2. 이슈 키 결정

- 인자로 전달된 경우: 그대로 사용 (예: `CONTENTSHUB-1234`)
- 인자 없는 경우: `gh pr view --json title --jq '.title'`에서 `[CONTENTSHUB-XXXX]` 패턴 추출

### 3. PR 정보 수집

```bash
gh pr view --json url,title,body --jq '{url, title, body}'
```

### 4. 코멘트 작성

PR의 변경사항을 분석하여 **일본어 3줄 요약 + 한국어 3줄 요약**을 작성한다.

코멘트 형식:
```
PR: {PR URL}

{일본어 요약 1}
{일본어 요약 2}
{일본어 요약 3}

---

{한국어 요약 1}
{한국어 요약 2}
{한국어 요약 3}
```

- 일본어가 먼저, 구분선(`---`) 아래에 한국어를 병기
- 일본어는 자연스러운 비즈니스 일본어로 작성 (입니다/ます 체)
- 한국어는 간결한 개조식

### 5. Backlog API 호출 및 결과 파싱

> **주의**: Backlog API 응답의 `content` 필드에 raw 개행 문자가 포함되어 `jq`와 `python3 json.loads`가 파싱에 실패한다.
> 응답에서 Comment ID만 필요하므로 `grep -o`로 추출한다.

```bash
RESULT=$(curl -s -X POST "https://${SPACE_KEY}.${DOMAIN}/api/v2/issues/${ISSUE_KEY}/comments?apiKey=${API_KEY}" \
  --data-urlencode "content=${COMMENT}")

COMMENT_ID=$(echo "$RESULT" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
```

- `COMMENT_ID`가 비어있으면 API 호출 실패 — `$RESULT` 원문을 출력하여 에러 원인을 안내한다.
- 성공 시 코멘트 ID와 이슈 키를 출력한다.
