## 개발자 컨텍스트

- 시니어 Android/Flutter 개발자
- 현재 주로 Flutter macOS 앱 작업 중

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
