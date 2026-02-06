# Flutter 공식 AI Rules

> 출처: https://github.com/flutter/flutter/blob/main/docs/rules/rules.md

## Interaction Guidelines
- Dart에 익숙하지 않을 수 있는 사용자를 가정. null safety, futures, streams 등 설명 포함.
- 모호한 요청 시 기능과 타겟 플랫폼 명확히 확인.
- pub.dev 의존성 추가 시 이점 설명.
- `dart_format`, `dart_fix`, `analyze_files` 도구 적극 활용.

## Project Structure
- 표준 Flutter 프로젝트 구조, `lib/main.dart` 진입점.

## Style Guide
- **SOLID 원칙** 적용.
- 간결하고 선언적인 Dart 코드. 함수형/선언적 패턴 선호.
- **상속보다 조합(Composition over Inheritance)**.
- **불변성(Immutability)** 선호. `StatelessWidget`은 불변.
- 임시 상태와 앱 상태 분리.
- 모든 UI는 위젯. 작은 위젯으로 조합.
- 라우팅: `go_router` 또는 `auto_route`.

## Package Management
- `pub` 도구 우선 사용.
- `pub_dev_search` 도구로 패키지 검색.
- `flutter pub add <package>`, `dev:<package>`, `override:<package>:version`.

## Code Quality
- UI 로직과 비즈니스 로직 분리.
- 약어 금지, 의미있는 이름 사용.
- `PascalCase` (클래스), `camelCase` (멤버/변수/함수/enum), `snake_case` (파일).
- 함수는 20줄 미만, 단일 목적.
- `logging` 패키지 사용 (`print` 대신).

## Dart Best Practices
- Effective Dart 가이드라인 준수.
- 모든 public API에 문서 주석.
- `async`/`await` 올바른 사용, `Future`, `Stream` 활용.
- **Null Safety**: `!` 연산자 최소화.
- 패턴 매칭, Record, 완전한(exhaustive) switch 문 활용.
- 화살표 함수: 단순 한 줄 함수에 사용.

## Flutter Best Practices
- **Private Widget 클래스**: 헬퍼 메서드 대신 private Widget 클래스 사용.
- 큰 `build()` 메서드를 작은 private Widget 클래스로 분리.
- `ListView.builder`, `SliverList`로 긴 리스트 lazy-load.
- `compute()`로 무거운 계산을 별도 isolate에서 실행.
- `const` 생성자 적극 활용.
- `build()` 내에서 네트워크 호출, 복잡한 연산 금지.

## State Management (기본 규칙)
- **내장 솔루션 우선**: 명시적 요청 없이 서드파티 패키지 사용 금지.
- `Stream` + `StreamBuilder`: 비동기 이벤트 시퀀스.
- `Future` + `FutureBuilder`: 단일 비동기 작업.
- `ValueNotifier` + `ValueListenableBuilder`: 단순 로컬 단일 값 상태.
- `ChangeNotifier` + `ListenableBuilder`: 복잡하거나 공유 상태.
- **MVVM**: 더 견고한 솔루션 필요 시.
- **DI**: 생성자 주입으로 의존성 명시화.
- `provider`: 명시적 요청 시에만 사용.

## Application Architecture
- MVC/MVVM 유사 관심사 분리.
- 논리적 계층:
  - **Presentation**: 위젯, 스크린
  - **Domain**: 비즈니스 로직 클래스
  - **Data**: 모델 클래스, API 클라이언트
  - **Core**: 공유 클래스, 유틸리티, extension types
- 대규모 프로젝트: 기능별(feature-based) 구조.

## Routing
- `go_router`: 선언적 내비게이션, 딥 링크, 웹 지원.
- `redirect` 속성으로 인증 흐름 처리.
- `Navigator`: 딥 링크 불필요한 단기 화면(다이얼로그 등).

## Data Handling & Serialization
- `json_serializable` + `json_annotation`.
- `fieldRename: FieldRename.snake`로 camelCase → snake_case 변환.

## Logging
- `dart:developer`의 `log` 함수 사용.
- 구조화된 에러 로깅: `name`, `level`, `error`, `stackTrace` 포함.

## Code Generation
- `build_runner` dev dependency 필수.
- 코드 생성 후: `dart run build_runner build --delete-conflicting-outputs`

## Testing
- `run_tests` 도구 우선 사용.
- `package:test` (단위), `package:flutter_test` (위젯), `package:integration_test` (통합).
- `package:checks` 선호 (기본 matchers 대신).
- Arrange-Act-Assert 패턴.
- Mock보다 Fake/Stub 선호. 필요 시 `mockito` 또는 `mocktail`.

## Visual Design & Theming
- `ThemeData`로 중앙 집중 테마.
- `ColorScheme.fromSeed()`로 색상 팔레트 생성.
- Light/Dark 테마 모두 지원.
- `ThemeExtension`으로 커스텀 디자인 토큰.
- `WidgetStateProperty`로 상태별 스타일링.
- `google_fonts` 패키지로 커스텀 폰트.

## Layout Best Practices
- `Expanded`: 남은 공간 채우기.
- `Flexible`: 축소 가능하되 확대 불필요 시.
- `Wrap`: 오버플로우 방지.
- `ListView.builder` / `GridView.builder`: 긴 리스트/그리드.
- `LayoutBuilder` / `MediaQuery`: 반응형 UI.
- `OverlayPortal`: 커스텀 드롭다운, 툴팁 등 오버레이.

## Color & Font Best Practices
- WCAG 2.1 준수: 일반 텍스트 4.5:1, 큰 텍스트 3:1 대비.
- 60-30-10 법칙: Primary 60%, Secondary 30%, Accent 10%.
- 폰트 패밀리 1~2개 제한. 가독성 우선.
- line-height: 1.4x~1.6x, 줄 길이: 45~75자.

## Accessibility
- 색상 대비 4.5:1 이상.
- 동적 텍스트 스케일링 테스트.
- `Semantics` 위젯으로 시맨틱 라벨 제공.
- TalkBack(Android), VoiceOver(iOS) 테스트.

## Lint Rules
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # 추가 lint 규칙
```

## Assets
- `pubspec.yaml`에 에셋 경로 선언.
- 로컬: `Image.asset`, 네트워크: `Image.network` + `loadingBuilder` + `errorBuilder`.
- 캐시: `cached_network_image` 패키지.
