---
name: review-pr
description: |
  GitHub PR을 체크아웃하고 상세 리뷰 수행. PR 번호 또는 URL을 인자로 받음.
  트리거: "PR 리뷰", "PR 리뷰 해줘", "review pr", "PR #123 리뷰", "/review-pr" 등.
  코드 품질과 모범 사례 기준으로 리뷰하고, 사용자 승인 후 코멘트 게시.
---

# Review PR

GitHub PR을 체크아웃하여 상세 리뷰를 수행한다.

## 실행 절차

1. `gh pr view {PR번호}` 로 PR 정보 조회 (title, body, labels, base/head, checks)
2. PR 브랜치 로컬 체크아웃:
   - 우선: `gh pr checkout {PR번호}`
   - 필요 시: `gh pr view {PR번호} --json headRepository,headRefName,baseRefName` → `git fetch` + `git checkout`
3. `dart run build_runner build --delete-conflicting-outputs` 실행하여 코드 생성
4. `gh pr diff {PR번호}` 로 diff 확인
5. PR description으로 변경 의도 파악
6. 체크아웃된 브랜치에서 추가 컨텍스트 확인:
   - 필요 시 코드베이스 검색
   - diff에 완전히 보이지 않는 관련 파일 확인 (생성 파일, config, 템플릿 등)
   - 관련 시 로컬 검증 단계 실행 (테스트/빌드/린트)
7. 필요 시 flutter mcp, context7 mcp 활용

## 리뷰 규칙

- 한국어로 리뷰 작성
- 코드 품질과 모범 사례를 장려하는 방향으로 간결하게 작성
- 문제 없으면 코멘트 없이 결과만 알림

## 게시 전 확인 사항

- **반드시 사용자에게 먼저 확인** 후 리뷰 게시
- 머지 가능 여부 판단 후 사용자에게 승인 여부 질문

## 리뷰 게시

```bash
# 일반 코멘트
gh pr comment {PR번호} --body "{review}"

# 사용자가 승인하는 경우
gh pr review {PR번호} --approve --body "{review}"
```
