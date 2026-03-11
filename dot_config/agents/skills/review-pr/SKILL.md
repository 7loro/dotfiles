---
name: review-pr
description: |
  GitHub PR을 체크아웃하고 상세 리뷰 수행. PR 번호 또는 URL을 인자로 받음.
  트리거: "PR 리뷰", "PR 리뷰 해줘", "review pr", "PR #123 리뷰", "/review-pr" 등.
  코드 품질과 모범 사례 기준으로 리뷰하고, 사용자 승인 후 코멘트 게시.
---

# Review PR

GitHub PR을 체크아웃하여 상세 리뷰를 수행한다.
리뷰 결과는 프로젝트의 `.claude/review-pr/{PR번호}.md`에 저장되며, 다음 리뷰 시 참고한다.

---

## 모드 분기

### PR 번호가 주어진 경우

인자로 받은 PR 번호(들)를 바로 리뷰 단계로 진행한다.

### PR 번호가 주어지지 않은 경우

**Step 1. 현재 사용자 및 전체 open PR 조회**

```bash
# 현재 GitHub 로그인 사용자 확인
gh api user --jq '.login'

# open 상태 PR 전체 조회 (리뷰 정보 포함)
gh pr list --state open --json number,title,author,url,reviews,reviewRequests --limit 100
```

**Step 2. 내가 리뷰하지 않은 PR 필터링**

- `reviews` 배열에 현재 사용자의 `login`이 없는 PR만 추린다.
- 내가 작성한 PR(`author.login == 현재 사용자`)은 제외한다.

**Step 3. 목록 출력 후 AskUserQuestion으로 복수 선택**

필터링된 PR 목록을 아래 형식으로 출력한다:

```
미리뷰 PR 목록 (내가 리뷰하지 않은 open PR):

  [1] #312  제목 텍스트                    — @작성자
  [2] #298  또 다른 PR 제목                 — @작성자
  [3] #271  세 번째 PR                     — @작성자
```

그런 다음 **AskUserQuestion** 툴을 사용하여 사용자가 리뷰할 PR을 **복수 선택**할 수 있도록 묻는다.

- 선택지는 번호 인덱스 또는 PR 번호로 입력받는다. (예: "1,3" 또는 "312,271")
- "전체" 또는 "all" 입력 시 전체 목록을 리뷰한다.

---

## 리뷰 실행 절차 (선택된 각 PR에 대해 순서대로 실행)

### 1. 이전 리뷰 파일 확인

프로젝트 루트의 `.claude/review-pr/{PR번호}.md` 파일이 존재하면 읽어서 이전 리뷰 내용을 파악한다.
- 이전에 지적한 패턴이 반복되는지
- 이전 코멘트에서 요청한 수정사항이 반영되었는지
확인하여 연속성 있는 리뷰를 작성한다.

### 2. PR 정보 조회

```bash
gh pr view {PR번호} --json number,title,author,url,body,commits,baseRefName,headRefName,labels,updatedAt
```

### 3. Worktree 생성

PR 브랜치를 별도 worktree로 체크아웃하여 현재 작업 브랜치를 보호한다.
worktree 경로: `/tmp/review-pr-{PR번호}`
worktree 브랜치명: `review-pr-{PR번호}`

```bash
# PR의 head 브랜치명 확인
HEAD_REF=$(gh pr view {PR번호} --json headRefName --jq '.headRefName')

# 원격 브랜치 fetch
git fetch origin $HEAD_REF

# worktree 생성 (브랜치명: review-pr-{PR번호})
git worktree add /tmp/review-pr-{PR번호} -b review-pr-{PR번호} origin/$HEAD_REF

# review-pr-{PR번호} 브랜치가 이미 존재하면 강제 재생성
git worktree add /tmp/review-pr-{PR번호} -B review-pr-{PR번호} origin/$HEAD_REF
```

이후 모든 파일 탐색 및 코드 읽기는 `/tmp/review-pr-{PR번호}/` 경로를 기준으로 수행한다.

### 4. Diff 확인

```bash
gh pr diff {PR번호}
```

### 5. 추가 컨텍스트 확인

- PR description으로 변경 의도 파악
- diff에 보이지 않는 관련 파일은 worktree 경로(`/tmp/review-pr-{PR번호}/`)에서 직접 읽어 확인
- 필요 시 flutter MCP, context7 MCP 활용

---

## 리뷰 규칙

- 한국어로 리뷰 작성
- 코드 품질과 모범 사례를 장려하는 방향으로 간결하게 작성
- 문제 없으면 코멘트 없이 "문제 없음" 결과만 기록

---

## 리뷰 결과 저장

리뷰가 완료되면 **반드시** 아래 형식으로 `.claude/review-pr/{PR번호}.md`에 저장한다.
파일이 이미 존재하면 새 리뷰를 최상단에 추가(prepend)한다.

**리뷰 노트 생성 일시는 반드시 `date '+%Y-%m-%d %H:%M'` 명령으로 실제 현재 시각을 확인하여 기입한다.** 추정하거나 임의로 작성하지 않는다.

```markdown
# PR #{PR번호} 리뷰

## 메타데이터

| 항목 | 값 |
|------|-----|
| PR 주소 | {PR URL을 마크다운 링크가 아닌 원본 주소 그대로 기입} |
| 제목 | {PR 제목} |
| 작성자 | @{작성자 login} |
| 커밋 수 | {커밋 갯수}개 |
| PR 마지막 업데이트 | {PR의 updatedAt을 YYYY-MM-DD HH:mm KST로 변환하여 기입} |
| 리뷰 노트 생성 일시 | {이 리뷰 파일이 생성/추가되는 시점의 YYYY-MM-DD HH:mm} (KST) |

---

## 리뷰 내용

{리뷰 본문}

---

## 결정

- [ ] Approve
- [ ] Request Changes
- [ ] Comment Only

```

---

## 게시 전 확인 사항

파일 저장이 완료되면 아래 두 단계를 반드시 순서대로 수행한다.

**Step 1. 작성한 리뷰 내용을 텍스트로 출력한다.**

저장한 마크다운 파일의 최신 리뷰 섹션 전체를 사용자에게 코드 블록 없이 그대로 보여준다.

**Step 2. AskUserQuestion으로 게시 방법을 묻는다.**

머지 가능 여부를 판단한 후, 아래 선택지를 제시한다:
- LGTM (코멘트 없이 "LGTM" 텍스트만으로 Approve)
- Approve + 코멘트 게시
- Approve만 (코멘트 없음)
- Request Changes
- Comment Only
- 게시하지 않음

---

## 리뷰 게시

```bash
# 일반 코멘트
gh pr comment {PR번호} --body "{review}"

# 승인
gh pr review {PR번호} --approve --body "{review}"

# 변경 요청
gh pr review {PR번호} --request-changes --body "{review}"
```

---

## Worktree 정리 (리뷰 완료 후 반드시 실행)

리뷰 게시 여부와 무관하게, 리뷰가 끝나면 반드시 worktree를 제거한다.

```bash
# worktree 제거
git worktree remove /tmp/review-pr-{PR번호} --force

# 로컬에 생성된 review-pr 브랜치 삭제
git branch -D review-pr-{PR번호}
```

여러 PR을 연속으로 리뷰한 경우 각 PR의 worktree를 개별적으로 정리한다.
