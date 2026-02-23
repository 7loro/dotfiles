---
name: youtube-digest
description: >
  YouTube 영상을 분석하여 요약/인사이트/한글 번역 문서를 생성하고,
  3단계 학습 퀴즈로 이해도를 테스트하는 스킬.
  트리거: "유튜브 정리", "영상 요약", "transcript 번역", "YouTube digest",
  "영상 퀴즈", YouTube URL 제공 시.
---

# YouTube Digest

YouTube 영상 분석 → 요약/인사이트/번역 문서 생성 → 퀴즈 테스트.

## 워크플로우

### 1. 메타데이터 및 자막 추출

```bash
python3 scripts/extract_transcript.py "<URL>"
```

yt-dlp로 메타데이터(제목, 채널, 업로드일, 길이)와 자막을 동시 추출.
자막 우선순위: 수동(ko→en) > 자동(ko→en).

### 2. 맥락 파악 (WebSearch)

웹 검색으로 고유명사 정확한 표기 수집:
- `"{영상 제목}" {채널명} summary`
- `"{발표자명}" {주제 키워드}`

### 3. Transcript 교정

자동 자막의 고유명사 오인식을 웹 검색 결과로 대체:
- 예: Kora → Cora, cloud code → Claude Code

이해 불가 부분은 `[불명확]`으로 표시.

### 4. 문서 생성

```markdown
---
title: {영상 제목}
url: {YouTube URL}
channel: {채널명}
date: {업로드 날짜}
duration: {영상 길이}
processed_at: {처리 일시}
---

# {영상 제목}

## 요약
{3-5문장 요약 + 주요 포인트 3개}

## 인사이트
### 핵심 아이디어
### 적용 가능한 점

## 전체 스크립트 (한글 번역)
[00:00] ...
```

### 5. 파일 저장

위치: `research/readings/youtube/{YYYY-MM-DD}-{sanitized-title}.md`

### 6. 학습 퀴즈

3단계 × 3문제 = 총 9문제. AskUserQuestion으로 각 단계 3문제 동시 출제.

| 단계 | 난이도 | 출제 기준 |
|------|--------|----------|
| 1 | 기본 | 핵심 인사이트, 주요 개념 |
| 2 | 중급 | 인사이트 + 세부 내용 연결 |
| 3 | 심화 | 세부 내용, 적용/분석 |

문제 유형 상세: [references/quiz-patterns.md](references/quiz-patterns.md)

#### 결과 처리

틀린 문제에 대해 정답과 해설 제공 후, 문서 끝에 퀴즈 결과 추가:

```markdown
## 퀴즈 결과

총점: 7/9 (78%) | 1단계 3/3 | 2단계 2/3 | 3단계 2/3

### 오답 노트

**Q5**: {질문}
- 선택: B → 정답: C
- {1-2문장 해설}
```

### 7. 후속 선택

퀴즈 완료 후 AskUserQuestion:
- **한 번 더 퀴즈**: 다른 문제로 재테스트
- **Deep Research**: 웹 심층 조사 ([references/deep-research.md](references/deep-research.md) 참조)
- **종료**: 마무리

## 참고사항

- yt-dlp 필수: `brew install yt-dlp` 또는 `pip install yt-dlp`
- `--list-subs`: 자막 목록 확인
- `--cookies-from-browser chrome`: 로그인 필요 시

## 리소스

- `scripts/extract_transcript.py` - 메타데이터 + 자막 추출 (Python)
- `references/quiz-patterns.md` - 퀴즈 문제 유형 상세
- `references/deep-research.md` - Deep Research 워크플로우
