---
name: make-backlog-comment
description: Backlog 이슈에 PR 주소와 변경사항 요약 코멘트를 한국어로 남기는 스킬. 현재 브랜치의 PR 정보를 분석하여 3줄 요약을 자동 생성하고 Backlog API로 코멘트를 등록한다. 트리거 - "backlog 코멘트", "백로그 코멘트", "코멘트 남겨", "PR 코멘트 backlog", "이슈에 코멘트", "make-backlog-comment" 등. PR을 올린 후 Backlog 이슈에 작업 내용을 기록하고 싶을 때, 또는 이슈 키를 지정하여 코멘트를 남기고 싶을 때 사용한다. 일본어 병기가 필요하면 make-backlog-comment-jp 스킬을 대신 사용한다.
---

# Make Backlog Comment

Backlog 이슈에 PR 주소와 변경사항 요약 코멘트를 한국어로 남긴다.

## 사용법

```
/make-backlog-comment CONTENTSHUB-1234
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

PR의 변경사항을 분석하여 **한국어 3줄 요약**을 작성한다.

코멘트 형식:
```
PR: {PR URL}

- {변경사항 요약 1}
- {변경사항 요약 2}
- {변경사항 요약 3}
```

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
