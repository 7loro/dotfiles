---
name: flutter-expert
description: >
  Flutter/Dart 코드 작성, 리뷰, 리팩토링을 위한 전문가 스킬.
  Flutter 공식 AI rules 기반으로 위젯 설계, 상태 관리, 테마, 라우팅, 테스트, 아키텍처 가이드를 제공한다.
  Riverpod 상태 관리 전문 지식 포함: AsyncNotifierProvider, 코드 생성, Repository 패턴, Family Provider,
  autoDispose, 성능 최적화, 테스트 패턴 등 2025 모범 사례를 제공한다.
  트리거: Flutter/Dart 코드 작성, 위젯 구현, 상태 관리 설계, 테마/스타일링, 라우팅 설정,
  Flutter 테스트 작성, Flutter 프로젝트 구조 설계, pubspec.yaml 수정,
  "flutter", "dart", "위젯", "widget", "riverpod", "provider", "AsyncNotifier" 등의 키워드가 포함된 코드 작업 시.
---

# Flutter Expert

Flutter/Dart 개발의 모범 사례와 공식 AI rules를 적용하여 코드를 작성한다.

## 핵심 원칙

1. **프로젝트 규칙 우선**: 프로젝트에 CLAUDE.md, analysis_options.yaml, 아키텍처 문서 등 자체 규칙이 있으면 해당 규칙을 최우선으로 따른다. 특히 **상태 관리는 프로젝트 내 규칙이 있으면 반드시 프로젝트 규칙을 따른다** (예: Riverpod, Bloc, GetX 등).
2. **공식 Flutter AI Rules 준수**: 프로젝트 규칙이 없는 영역은 [Flutter 공식 rules](references/flutter-rules.md)를 따른다.
3. **MCP Dart 도구 활용**: 가능한 한 shell 명령 대신 MCP Dart 도구를 사용한다.

## 작업 시작 워크플로우

1. **프로젝트 규칙 확인**: CLAUDE.md, README, 아키텍처 문서에서 프로젝트 컨벤션 파악.
2. **기존 패턴 파악**: 프로젝트 내 기존 코드의 상태 관리, 라우팅, 아키텍처 패턴 확인.
3. **기존 패턴에 맞춰 코드 작성**: 일관성을 유지하며 새 코드 작성.

## MCP Dart 도구 활용

| 작업 | 도구 |
|------|------|
| 패키지 검색 | `pub_dev_search` |
| 패키지 추가/제거 | `pub` (add, remove, get, upgrade) |
| 코드 분석 | `analyze_files` |
| 코드 포맷팅 | `dart_format` |
| 자동 수정 | `dart_fix` |
| 테스트 실행 | `run_tests` |
| 프로젝트 생성 | `create_project` |
| 앱 실행/디버깅 | `launch_app`, `hot_reload`, `hot_restart` |
| 위젯 트리 확인 | `get_widget_tree`, `get_selected_widget` |
| 심볼 검색 | `resolve_workspace_symbol` |
| API 확인 | `hover`, `signature_help` |

## 상태 관리 결정 트리

```
프로젝트에 상태 관리 규칙이 있는가?
├─ YES → 프로젝트 규칙 따르기
│        ├─ Riverpod → references/riverpod-best-practices.md 참조
│        ├─ Bloc, GetX 등 → 해당 패턴 준수
│        └─ 핵심: AsyncNotifierProvider 우선, 코드 생성 권장
└─ NO → Flutter 내장 솔루션 사용
         ├─ 단일 값, 로컬 상태 → ValueNotifier + ValueListenableBuilder
         ├─ 복잡/공유 상태 → ChangeNotifier + ListenableBuilder
         ├─ 비동기 단일 작업 → Future + FutureBuilder
         ├─ 비동기 이벤트 시퀀스 → Stream + StreamBuilder
         └─ 견고한 구조 필요 → MVVM 패턴 + 생성자 DI
```

### Riverpod 사용 시 핵심 가이드

프로젝트에서 Riverpod을 사용하는 경우 아래 원칙을 따른다:

- **코드 생성 강력 권장**: `@riverpod` 어노테이션 + `riverpod_generator` 사용.
- **AsyncNotifierProvider 우선**: 비동기 상태에는 FutureProvider 대신 AsyncNotifierProvider 사용.
- **ref.select()로 성능 최적화**: 특정 필드만 구독하여 불필요한 리빌드 방지.
- **Repository 패턴**: Data → Application → Presentation 3계층 분리.
- **AutoDispose 기본**: 코드 생성 시 자동 적용. `@Riverpod(keepAlive: true)`로 영구 캐싱.
- 상세 패턴 및 예제: → [references/riverpod-best-practices.md](references/riverpod-best-practices.md)

## 코드 작성 규칙 요약

### 위젯 설계
- `StatelessWidget`은 불변으로 유지.
- 헬퍼 메서드 대신 **private Widget 클래스**로 분리.
- `const` 생성자 적극 활용하여 리빌드 최소화.
- `build()` 내에서 네트워크 호출, 무거운 연산 금지.

### 네이밍
- `PascalCase`: 클래스, enum 타입.
- `camelCase`: 변수, 함수, 멤버, enum 값.
- `snake_case`: 파일명.
- 약어 금지, 의미있는 이름 사용.

### 아키텍처
- **Presentation** (위젯, 스크린) / **Domain** (비즈니스 로직) / **Data** (모델, API) / **Core** (공유 유틸리티).
- 대규모 프로젝트: 기능별(feature-based) 구조 적용.

### 라우팅
- 기본: `go_router` (선언적 내비게이션, 딥 링크).
- 단기 화면 (다이얼로그 등): `Navigator`.

### 테스트
- Arrange-Act-Assert 패턴.
- `package:checks`로 표현력 있는 assertion.
- Mock보다 Fake/Stub 선호.

### 코드 생성
- `json_serializable` 사용 시 `build_runner` dev dependency 추가.
- 수정 후: `dart run build_runner build --delete-conflicting-outputs`

## 상세 레퍼런스

| 문서 | 내용 |
|------|------|
| [references/flutter-rules.md](references/flutter-rules.md) | Flutter 공식 AI rules (테마, 레이아웃, 접근성, 색상, 폰트 등) |
| [references/riverpod-best-practices.md](references/riverpod-best-practices.md) | Riverpod 2025 모범 사례 (Provider 선택, 코드 생성, 성능 최적화, Repository 패턴, Family, AutoDispose, 에러 처리, 테스트, 안티패턴) |
