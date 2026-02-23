---
name: tech-decision
description: >
  기술 의사결정을 체계적으로 분석하는 오케스트레이션 스킬.
  라이브러리 선택, 아키텍처 결정, 구현 방식 비교 등 기술 의사결정 시
  코드베이스 분석, 공식 문서 리서치, 커뮤니티 의견 수집, 트레이드오프 분석을
  체계적으로 수행하여 두괄식 종합 보고서를 생성한다.
  트리거: "뭐가 나을까", "비교해줘", "어떤 걸 써야", "tech decision",
  "라이브러리 추천", "아키텍처 결정", "기술 선택", "A vs B" 등.
---

# Tech Decision

기술 의사결정을 체계적으로 분석하여 **두괄식**(결론 먼저) 종합 보고서를 생성한다.

## 핵심 원칙

1. **결론 먼저**: 모든 보고서는 결론을 맨 처음에 제시한다.
2. **증거 기반**: 모든 주장에 출처를 명시한다.
3. **다각적 분석**: 아키텍트, 시니어 개발자, DevOps, 비즈니스 4가지 관점에서 분석한다.
4. **프로젝트 맥락**: 일반론이 아닌 현재 프로젝트에 맞춘 판단을 제시한다.

## 워크플로우

```
Phase 1 (순차): 문제 정의
  ↓
Phase 2a (순차): codebase-explorer — 프로젝트 맥락 확보 (선행 필수)
  ↓
Phase 2b (병렬): docs-researcher + dev-scan — 독립 실행
  ↓
Phase 3 (순차): tradeoff-analyzer — 2a + 2b 결과 종합 + 관점 분석
  ↓
Phase 4 (순차): decision-synthesizer — 최종 보고서
```

---

### Phase 1: 문제 정의

사용자 요청을 분석하여 의사결정 프레임을 수립한다.

```
1. 주제 파악
   - 비교 대상 기술/옵션 식별
   - 의사결정 유형 분류 (라이브러리, 아키텍처, 구현 방식, DB 등)

2. 옵션 식별
   - 명시된 옵션 정리
   - 추가 고려 대상이 있으면 사용자에게 제안

3. 평가 기준 수립
   - references/evaluation-criteria.md에서 유형별 기본 기준 참조
   - 사용자가 명시한 우선순위 반영
   - 프로젝트 상황에 맞게 가중치 조정
```

---

### Phase 2a: 코드베이스 분석 (선행 — 순차)

**codebase-explorer** 에이전트를 Task tool로 실행하여 프로젝트 맥락을 확보한다.
이 결과는 Phase 2b와 Phase 3에서 참조되므로 반드시 먼저 완료한다.

```
Task tool 호출:
  - subagent_type: general-purpose
  - name: codebase-explorer
  - prompt: |
      agents/codebase-explorer.md의 프로세스에 따라 코드베이스를 분석하라.
      분석 주제: {주제}
      비교 대상: {옵션들}
      현재 프로젝트의 기술 스택, 아키텍처 패턴, 의존성, 제약사항을 파악하라.
```

> **주의**: 프로젝트 컨텍스트가 없는 일반적인 기술 비교 요청이라면 이 단계를 건너뛸 수 있다.

---

### Phase 2b: 정보 수집 (병렬)

아래 두 작업을 **Task tool로 병렬 실행**한다.

#### docs-researcher

```
Task tool 호출:
  - subagent_type: general-purpose
  - name: docs-researcher
  - prompt: |
      agents/docs-researcher.md의 프로세스에 따라 리서치를 수행하라.
      비교 주제: {주제}
      비교 대상: {옵션들}
      Context7 MCP를 1순위로 사용하여 공식 문서를 먼저 확인하고,
      WebSearch로 벤치마크, 커뮤니티 규모, 실제 사례를 보완 수집하라.
      검색 시 현재 연도를 사용하라.
```

#### dev-scan

```
Skill tool 호출: dev-scan
  - args: {주제}

또는 Task tool 호출:
  - subagent_type: general-purpose
  - name: dev-scan
  - prompt: |
      skills/dev-scan/SKILL.md의 워크플로우에 따라 커뮤니티 의견을 수집하라.
      주제: {주제}
      해외 4개 소스(Reddit, HN, Dev.to, Lobsters) + 국내 개발 커뮤니티를 모두 검색하라.
```

---

### Phase 3: 트레이드오프 분석 (순차)

Phase 2a + 2b의 모든 결과를 종합하여 **tradeoff-analyzer** 에이전트를 실행한다.

```
Task tool 호출:
  - subagent_type: general-purpose
  - name: tradeoff-analyzer
  - prompt: |
      agents/tradeoff-analyzer.md의 프로세스에 따라 분석을 수행하라.
      아래 입력 데이터를 종합하여 구조화된 비교 분석을 작성하라.

      ## 입력 데이터

      ### 코드베이스 분석 (codebase-explorer)
      {Phase 2a 결과}

      ### 문서 리서치 (docs-researcher)
      {Phase 2b-1 결과}

      ### 커뮤니티 의견 (dev-scan)
      {Phase 2b-2 결과}

      ## 평가 기준 및 가중치
      {Phase 1에서 수립한 기준}

      4가지 관점(아키텍트, 시니어 개발자, DevOps, 비즈니스)에서 순회 분석을 수행하라.
```

---

### Phase 4: 최종 보고서 (순차)

Phase 3의 트레이드오프 분석 결과를 기반으로 **decision-synthesizer** 에이전트를 실행한다.

```
Task tool 호출:
  - subagent_type: general-purpose
  - name: decision-synthesizer
  - prompt: |
      agents/decision-synthesizer.md의 프로세스에 따라 최종 보고서를 생성하라.
      references/report-template.md 템플릿을 참조하라.

      ## 입력 데이터

      ### 트레이드오프 분석 결과
      {Phase 3 결과}

      ### 프로젝트 맥락 (코드베이스 분석)
      {Phase 2a 결과 요약}

      두괄식으로 결론을 먼저 제시하고, 모든 주장에 출처를 명시하라.
      신뢰도 레벨(높음/중간/낮음)을 반드시 포함하라.
```

---

## 보고서 유형 선택

| 조건 | 유형 |
|------|------|
| 비교 대상 3개 이상 또는 복잡한 주제 | **전체 버전** (10섹션) |
| 비교 대상 2개, 비교적 단순 | **간소화 버전** (Quick Decision, 4섹션) |
| 사용자가 "간단하게", "빠르게" 요청 | **간소화 버전** |

## 참조 문서

| 문서 | 용도 |
|------|------|
| [references/evaluation-criteria.md](references/evaluation-criteria.md) | 유형별 평가 기준 및 가중치 |
| [references/report-template.md](references/report-template.md) | 두괄식 보고서 템플릿 (전체/간소화) |

## 주의사항

- **순서 준수**: Phase 2a(codebase-explorer)는 반드시 Phase 2b보다 먼저 완료한다.
- **병렬 실행**: Phase 2b의 docs-researcher와 dev-scan은 병렬로 실행하여 시간을 절약한다.
- **연도 동적 처리**: 검색 시 하드코딩된 연도 대신 현재 연도를 사용한다.
- **출처 일관성**: 전체 워크플로우에서 `[출처 제목](URL)` 형식의 출처 표기를 일관되게 유지한다.
- **프로젝트 맥락 우선**: 일반적인 기술 비교가 아닌, 현재 프로젝트 상황에 맞춘 추천을 제공한다.
