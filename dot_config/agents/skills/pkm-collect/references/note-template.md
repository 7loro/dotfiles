# work-note 구조 레퍼런스 (pkm-collect 노트 작성용)

frontmatter (frontmatter.md 준수):
---
created: {YYYY-MM-DD HH:MM:SS}
modified: {YYYY-MM-DD HH:MM:SS}
date: {YYYY-MM-DD}
tags:
  - {work|personal}      # base 정확히 1개
  - {주제태그}            # tag.md 허용목록 (feature/fix/refactor/troubleshooting/dev…)
---

본문 (writing-guide.md work-note 구조, 파일명과 같은 H1 금지):

>[!summary]
>- 핵심 1
>- 핵심 2

# 목적
작업 배경/목적.

# 작업 내용
## 상세
구체 작업.
## 기술적 고려사항
- …

# 결과
결과 요약.

# 참고
- 세션: {claude/codex} {session_id 앞 8자}
- 브랜치: {branch}
- {관련 PR/링크/[[관련 노트]]}
