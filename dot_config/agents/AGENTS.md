## 응답 규칙

- 모든 응답은 **한글**로 작성
- 사고 과정(thinking)도 **한글**로 표시

## 작업 진행 표시

Tool, Agent, Team, Sub-agent 등을 사용할 때 아래 형식으로 **사용 전 한 줄 안내**를 출력할 것:

- 🔧 **Tool** — `🔧 `Read` 파일 읽는 중...`, `🔧 `Grep` 코드 검색 중...`
- 🤖 **Agent** — `🤖 `Explore` 코드베이스 조사 위임`
- 👥 **Team** — `👥 `team-name` 팀 생성: 프론트엔드 + 백엔드 병렬 작업`
- 🧩 **Sub-agent** — `🧩 `agent-name` 서브 에이전트: 테스트 검증`
- 🎯 **Skill** — `🎯 `/flutter-expert` 스킬 실행`
- 📋 **Task** — `📋 `TaskCreate` API 연동 구현`
- ⚡ **Bash** — `⚡ `Bash` 빌드 실행 중...`

## 코드 작성 규칙

- 주석은 **한글**로 작성
- 커밋 제목은 **한글** 작성 (type prefix 제외, 예: `fix: 소설 목록 로딩 오류 수정`)
- 한 줄 최대 길이: **150자**
- **Trailing comma** 항상 적용

## Dart 코드 규칙

- `whereNotNull` 사용 금지 → `nonNulls` 사용
- `withOpacity` 사용 금지 (deprecated) → `withValues(alpha:)` 사용
- Riverpod 3.0: `XxxRef` 사용 금지 (deprecated) → `Ref` 사용

## 금지 명령어

- `dart format .` 실행 금지 — 전체 파일을 변경하므로 소규모 커밋에 방해됨
- `dart fix --apply` 실행 금지 — 동일한 이유

## 스킬 사용

- Flutter/Dart 코드를 작성, 리뷰, 리팩토링할 때는 반드시 `/flutter-expert` 스킬을 먼저 실행할 것
- PR 생성 시 `/make-pr` 스킬을 사용할 것
- Git 관련 작업(커밋 분할, rebase, squash, history 검색 등)을 할 때는 `/git-master` 스킬을 활용할 것
