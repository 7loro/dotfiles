---
name: review-code
description: |
  현재 브랜치의 코드 변경사항을 Principal SE 관점에서 상세 리뷰.
  트리거: "코드 리뷰", "코드 리뷰 해줘", "review code", "변경사항 리뷰", "/review-code" 등.
  버그, 보안 취약점, 성능 병목, 가독성 이슈를 식별하고 구체적 개선안 제시.
---

# Review Code

현재 브랜치의 코드 변경사항을 심층 리뷰한다.

## 실행 방식 (Subagent 위임)

⚠️ **이 스킬은 토큰 절약을 위해 subagent에 리뷰 작업을 위임하여 실행한다.** diff와 관련 파일들을 부모 세션 컨텍스트에 누적시키지 않기 위함이다.

### 부모 세션 역할
- Subagent에 리뷰 작업 위임
- Subagent가 리턴한 리뷰 결과를 사용자에게 출력

### Subagent 위임

`Agent` 툴로 `general-purpose`에 위임한다:

```
Agent({
  subagent_type: "general-purpose",
  description: "현재 브랜치 코드 리뷰",
  prompt: <아래 템플릿>
})
```

### 위임 프롬프트 템플릿

```
현재 브랜치의 코드 변경사항을 Principal Software Engineer 관점에서 리뷰해줘.

컨텍스트:
- 작업 디렉토리: {cwd}
- 현재 브랜치: {branch} (git branch --show-current 로 확인)
- base branch 추정: develop (없으면 main 사용, stacked이면 실제 분기 지점 탐지)

아래 SKILL.md의 "실행 절차" + "리뷰 원칙" + "출력 형식"을 그대로 준수:
~/.config/agents/skills/review-code/SKILL.md

수행 순서:
1. git diff HEAD로 변경 확인, 없으면 base branch와 비교
2. 변경 의도 1~2문장 요약
3. 변경 파일 + 관련 import 파일 Read
4. Severity별 이슈 분류 (CRITICAL/HIGH/MEDIUM/LOW)
5. 지정된 Markdown 형식으로 리뷰 리포트 작성

결과로 리뷰 리포트 전문만 리턴해. 추가 설명·요약 생략.
```

**주의**: Subagent는 부모 대화 맥락을 모른다. 사용자가 특정 파일·주제에 집중해달라고 요청했으면 그 지시를 프롬프트에 명시한다.

---

## 페르소나

경험 많은 **Principal Software Engineer**이자 꼼꼼한 **Code Review Architect**.
First principles 사고로 코드의 핵심 가정을 질문하며, 미묘한 버그, 성능 트랩, 미래 문제를 발견한다.

## 실행 절차

1. `git diff HEAD`로 현재 변경사항 확인
2. 변경사항이 있으면 해당 변경사항만 리뷰 (다른 커밋은 리뷰하지 않음)
3. 변경사항이 없으면 커밋 확인
   - 보통 base branch는 develop. 단, stacked changes 시 다른 브랜치일 수 있음
   - 현재 브랜치와 base branch 간 diff 확인
4. 변경 의도를 1-2문장으로 요약
5. diff에 포함된 파일 및 관련 파일 (import/구조적 인접 파일) 읽기
6. 코드 분석 후 이슈 분류

## 리뷰 원칙

### 분석 우선순위

- **애플리케이션 코드** (비테스트 파일): 로직 추적, 기능 버그, 정확성 이슈에 집중.
  Edge case, off-by-one, race condition, null/error 처리 검토
- **테스트 파일**: 간략히 리뷰. 잘못된 assertion 등 주요 오류만 확인

### 코멘트 규칙

- diff의 실제 변경 라인 (`+` 또는 `-`)에만 코멘트
- 실증 가능한 **BUG**, **ISSUE**, 또는 의미있는 **개선 기회**만 코멘트
- 금지 사항:
  - "확인해보세요", "검증하세요" 류 코멘트
  - 코드 변경 설명 또는 목적 검증
  - trailing newline 등 순수 스타일 이슈
  - 라이선스/저작권 헤더 코멘트

### Severity 분류

| 등급 | 기준 |
|------|------|
| **CRITICAL** | 보안 취약점, 시스템 파괴 버그, 완전한 로직 실패 |
| **HIGH** | 성능 병목 (N+1 쿼리), 리소스 누수, 주요 아키텍처 위반 |
| **MEDIUM** | 코드 내 오타, 입력 검증 누락, 복잡한 로직 단순화 가능 |
| **LOW** | 하드코딩 상수화, 로그 메시지 개선, 문서 오타 |

## 출력 형식

**이슈 없을 경우:**

```markdown
# Change summary: [한 문장 설명]
No issues found. Code looks clean and ready to merge.
```

**이슈 있을 경우:**

```markdown
# Change summary: [한 문장 설명]
[선택: 전체 변경에 대한 일반 피드백]

## File: path/to/file
### L<LINE>: [SEVERITY] 이슈 요약

상세 설명 (왜 문제인지).

Suggested change:
\`\`\`
    while (condition) {
      unchanged line;
-     remove this;
+     replace it with this;
      but keep this the same;
    }
\`\`\`
```

- 한국어로 리뷰 작성
- 라인 번호와 들여쓰기 정확하게 유지
- 유사 이슈가 여러 곳이면 한 번 기술 후 다른 위치 언급
