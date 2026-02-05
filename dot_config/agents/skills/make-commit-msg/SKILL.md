---
name: make-commit-msg
description: |
  staged 변경사항 기반으로 5개의 Git 커밋 메시지 후보를 생성.
  트리거: "커밋 메시지 추천", "커밋 메시지 생성", "commit message", "/make-commit-msg" 등.
  사용자가 type을 인자로 제공하면 해당 type으로 강제 적용.
---

# Make Commit Message

staged 변경사항만 분석하여 정확히 5개의 커밋 메시지 후보를 생성한다.

## 실행 절차

1. `git diff --staged` 실행하여 staged 변경사항 확인
2. staged 변경사항이 없으면 사용자에게 알림
3. 변경사항 분석 후 5개 커밋 메시지 생성

## Type 규칙

- 사용자가 type을 지정하면 (예: "feat", "fix") 모든 후보에 해당 type 강제 적용
- 지정하지 않으면 변경사항에 맞는 type 선택: feat, fix, refactor, build, docs, style, test, chore

## 출력 규칙

1. **형식**: 5개 메시지만 출력. 번호, 마크다운, 볼드 없이 한 줄씩
2. **구조**: `{type}: {description}`
3. **길이**: 각 줄 80자 이하
4. **언어**: 한국어
5. **대소문자**: 콜론 뒤 설명은 소문자로 시작
6. **시제**: 명령형 (예: "add", "fix", "update")

## 5개 메시지의 관점 다양성

1. 고수준 기능 요약
2. 구체적 기술 구현 상세
3. 영향 기반 (이 변경이 무엇을 가능하게 하는지)
4. 코드 구조/개선 관점
5. 파일/모듈 중심 포커스

## 출력 예시 (type이 'feat'인 경우)

```
feat: add user authentication logic to login controller
feat: implement jwt token verification middleware
feat: enable secure password hashing for new users
feat: refactor session management for better scalability
feat: update auth service to handle oauth2 callbacks
```
