# 문서 탐색 전략

## 개요

웹 문서를 BFS(너비 우선 탐색) 기반으로 체계적으로 탐색한다.
시작 URL에서 네비게이션 링크를 추출하고, 우선순위에 따라 하위 페이지를 탐색한다.

## 탐색 프로세스

### Step 1: 시작 페이지 분석

WebFetch로 시작 URL을 가져온 후 다음 프롬프트로 구조를 추출한다:

```
"이 페이지의 다음 정보를 JSON으로 추출해주세요:
1. title: 문서 제목
2. description: 문서 주제 설명 (1~2문장)
3. links: 학습 관련 링크 배열
   - title: 링크 텍스트
   - url: 절대 URL
   - category: getting-started | tutorial | concepts | api-reference | guide | example | other
4. navigation: 사이드바/메뉴 구조가 있다면 계층적으로 추출
외부 사이트 링크는 제외하고, 같은 도메인의 문서 링크만 포함해주세요."
```

### Step 2: 링크 우선순위 정렬

추출된 링크를 다음 우선순위로 정렬한다:

| 순위 | 카테고리 | 가중치 | 이유 |
|------|---------|--------|------|
| 1 | getting-started | 10 | 학습 시작점 |
| 2 | tutorial | 8 | 실습 중심 학습 |
| 3 | concepts | 7 | 핵심 개념 이해 |
| 4 | guide | 5 | 실용적 가이드 |
| 5 | api-reference | 3 | 참고용 |
| 6 | example | 4 | 코드 예시 |
| 7 | other | 1 | 기타 |

### Step 3: BFS 탐색 실행

```
탐색 규칙:
- 기본 깊이(depth): 1 (시작 URL → 직접 링크된 페이지)
- 최대 깊이: 2 (사용자 요청 시만)
- 최대 페이지 수: 20
- 같은 도메인만 탐색
- 이미 탐색한 URL은 건너뜀
- 앵커 링크(#)는 같은 페이지 내 섹션으로 처리
```

### Step 4: 각 페이지 콘텐츠 추출

하위 페이지 탐색 시 다음 프롬프트를 사용한다:

```
"이 페이지의 학습 콘텐츠를 다음 형식으로 요약해주세요:
1. title: 페이지 제목
2. summary: 핵심 내용 요약 (3~5문장)
3. keyTopics: 다루는 주요 주제 목록
4. codeExamples: 코드 예시 존재 여부 (true/false)
5. difficulty: 추정 난이도 (beginner/intermediate/advanced)
6. prerequisites: 이 내용을 이해하기 위해 필요한 선수 지식
7. subLinks: 이 페이지에서 추가로 탐색할 만한 링크 (같은 도메인만)"
```

## 난이도 추정 기준

### URL 구조 기반

- `/getting-started`, `/quickstart`, `/intro` → beginner
- `/guide`, `/tutorial`, `/learn` → beginner ~ intermediate
- `/advanced`, `/deep-dive`, `/internals` → advanced
- `/api`, `/reference` → intermediate ~ advanced

### 내용 복잡도 기반

- 기본 문법, 설치 방법, Hello World → beginner
- 패턴, 비교, 실습, Best Practices → intermediate
- 성능, 최적화, 내부 구조, 커스텀 구현 → advanced

## 학습 순서 최적화

탐색 완료 후 다음 기준으로 학습 순서를 결정한다:

1. **선수 지식 의존성**: A가 B의 prerequisites에 포함되면 A를 먼저
2. **난이도 순서**: beginner → intermediate → advanced
3. **문서 구조**: 원문서의 네비게이션 순서를 존중
4. **주제 연관성**: 관련 주제를 연속으로 배치

## 에러 처리

### WebFetch 실패

- **단일 페이지 실패**: 해당 페이지를 건너뛰고, 탐색 가능한 다른 페이지로 진행
- **리다이렉트**: 리다이렉트 URL로 재시도
- **30% 이상 실패**: 사용자에게 알리고, 성공한 페이지만으로 학습 구성 가능한지 확인

### 콘텐츠 추출 실패

- JSON 파싱 실패 시 자연어 응답에서 정보를 추출
- 빈 페이지나 의미 없는 페이지는 자동 제외

## 탐색 결과 구조

최종적으로 다음 구조의 데이터를 생성한다:

```json
{
  "sourceUrl": "https://example.com/docs",
  "topic": "Example Framework",
  "totalPages": 15,
  "exploredPages": [
    {
      "url": "https://example.com/docs/getting-started",
      "title": "Getting Started",
      "summary": "...",
      "difficulty": "beginner",
      "keyTopics": ["installation", "setup"],
      "category": "getting-started"
    }
  ],
  "suggestedOrder": [0, 3, 1, 4, 2],
  "failedUrls": []
}
```
