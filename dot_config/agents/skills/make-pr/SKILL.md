---
name: make-pr
description: |
  변경사항 커밋, 브랜치 푸시, 드래프트 PR 생성을 자동화하는 워크플로우.
  트리거: "PR 만들어", "PR 생성해줘", "PR 생성", "풀리퀘스트 생성", "PR 올려", "make pr", "/make-pr" 등.
  Stacked PR 지원 및 PR 템플릿 자동 생성.
argument-hint: "[PR 제목]"
---

# Make PR

변경사항 커밋, 브랜치 푸시, 드래프트 PR 생성을 자동화한다.

## 1. Commit & Push

- 미커밋 로컬 변경사항이 있으면 make-commit 스킬로 커밋 생성 (한국어 메시지)
- 현재 브랜치가 리모트에 없으면 브랜치 푸시

## 2. Base Branch 선택

현재 브랜치가 어디서 분기되었는지 확인하여 base branch를 결정한다.

### 탐지 방법

1. `git log --oneline --decorate` 로 현재 브랜치의 커밋 히스토리를 확인
2. 각 커밋에 붙은 branch ref를 역추적하여, 현재 브랜치가 갈라진 지점에 있는 브랜치를 찾는다
3. 또는 `git merge-base`를 활용하여 로컬 브랜치들과의 공통 조상을 비교한다

### 선택 규칙

- **기본 브랜치(develop/main)에서 직접 분기한 경우**: 해당 기본 브랜치를 base로 사용
- **다른 feature 브랜치에서 분기한 경우**: 해당 feature 브랜치를 base로 사용 (Stacked PR)
- **분기 지점을 판별할 수 없는 경우**: 리포지토리 기본 브랜치(develop 또는 main)를 fallback으로 사용

## 3. PR Title & Content

### Title

- **`$ARGUMENTS`가 전달된 경우**: 해당 값을 PR 제목으로 그대로 사용
- **`$ARGUMENTS`가 없는 경우**: 커밋 히스토리 기반으로 자동 생성
  - 형식: `{type}: {한국어 제목}` (예: `feat: 로그인 기능 구현`)
  - type은 영어 유지 (feat, fix, refactor, chore 등)

### Content

- 현재 브랜치와 base 브랜치 간 diff 분석
- 변경사항을 한국어로 요약
- 논리/흐름 변경 시 Mermaid 다이어그램 포함 가능

## 4. PR 생성

### 템플릿 구조

프로젝트 루트의 `.github/PULL_REQUEST_TEMPLATE.md` 파일 존재 여부를 먼저 확인한다.

- **템플릿 파일이 있는 경우**: 해당 파일의 양식을 기반으로 `pull_request.md` 작성
- **템플릿 파일이 없는 경우**: 아래 기본 템플릿으로 `pull_request.md` 작성

```markdown
## What does this PR do?

-

<!--
## Dependent PR

- https://github.kakaocorp.com/kjk/goomba-hub/pull/ Describe pr (Optional)

-->

<!--
## Screenshots

<table>
  <tr>
    <td align="center">Before</td>
    <td align="center">After</td>
  </tr>
  <tr><td colspan="2">설명이 필요하지 않는 경우 제거</td></tr>
  <tr>
    <td align="center"><img width="350" alt="" src=""></td>
    <td align="center"><img width="350" alt="" src=""></td>
  </tr>
</table>
-->
```

### CLI 명령

```bash
gh pr create --draft --assignee @me --title "[Title]" --body-file pull_request.md --base [BaseBranch]
```

### Cleanup

PR 생성 성공 후 `pull_request.md` 파일 삭제

## 5. 최종 출력

- PR URL 표시
- PR 제목 및 설명 표시
