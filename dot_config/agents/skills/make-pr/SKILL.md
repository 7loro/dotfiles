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

### 탐지 알고리즘

1. **GitHub 기본 브랜치 확인**: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`으로 기본 브랜치를 파악한다 (origin/HEAD는 로컬 캐시이므로 신뢰하지 않는다)
2. **분기점 탐지**: `git merge-base <candidate> HEAD`로 develop, main, 기타 로컬 브랜치 각각과의 공통 조상을 구한다
3. **가까운 쪽 선택**: 공통 조상이 HEAD에 더 가까운(더 최근인) 브랜치가 분기 원점이다
4. **동점 처리**: develop과 main의 merge-base가 동일한 커밋이면, GitHub 기본 브랜치를 우선 선택한다

### 선택 규칙 (우선순위 순)

1. **feature 브랜치에서 분기한 경우**: 해당 feature 브랜치를 base로 사용 (Stacked PR)
2. **develop에서 분기한 경우**: develop을 base로 사용
3. **main에서 분기한 경우**: main을 base로 사용
4. **분기 지점을 판별할 수 없는 경우**: GitHub 기본 브랜치(`gh repo view` 결과)를 fallback으로 사용

> ⚠️ `origin/HEAD`는 로컬 캐시이므로 실제 GitHub 설정과 다를 수 있다. 반드시 `gh repo view`로 확인한다.

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

> **⚠️ body 전달 규칙 — 반드시 준수**
> PR body는 항상 `pull_request.md` 파일로 작성한 뒤 `--body-file`로 전달한다.
> `--body "$(cat << 'EOF'...)"` 방식은 heredoc 내부의 backtick(`` ` ``)이 `\``로 escape되어 PR에 그대로 노출되는 문제가 있다.
> `gh pr edit` 등 수정 시에도 동일하게 임시 파일 방식을 사용한다:
> ```bash
> gh pr edit [number] --body-file pull_request.md
> ```

### Cleanup

PR 생성/수정 성공 후 `pull_request.md` 파일 삭제

## 5. 최종 출력

- PR URL 표시
- PR 제목 및 설명 표시

## 6. 세션 로그 분석 (Prompt Review)

PR 생성 성공 후, 이번 세션에서 사용한 프롬프트를 추출하고 품질을 평가한다. 평가 결과는 다음 단계의 PKM 문서에 포함된다.

### 6-1. 브랜치 작업 시작 시간 파악

현재 브랜치의 **첫 번째 커밋 타임스탬프**를 기준으로 세션 파일을 수집한다. 이를 통해 compact 이후 새 세션이 생성되거나 세션을 닫고 재시작한 경우에도 PR 관련 프롬프트를 빠짐없이 포함할 수 있다.

```bash
# base 브랜치와의 분기 이후 첫 커밋 시간 (Step 2에서 결정한 BaseBranch 사용)
BRANCH_START=$(git log --reverse --format="%aI" "${BASE_BRANCH}..HEAD" 2>/dev/null | head -1)

# 커밋이 없거나 파악 불가 시 현재로부터 24시간 전을 fallback으로 사용
if [ -z "$BRANCH_START" ]; then
  BRANCH_START=$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
    || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
    || date -u +%Y-%m-%dT%H:%M:%SZ)
fi
```

### 6-2. 프롬프트 추출

`--find-since` 옵션으로 브랜치 시작 시간 이후 수정된 세션 파일을 **모두** 수집하여 합친다:

```bash
SKILL_DIR="$HOME/.claude/skills/make-pr"
EXTRACT_RESULT=$(python3 "$SKILL_DIR/scripts/extract_prompts.py" \
  --find-since "$(pwd)" \
  --since "$BRANCH_START")
```

- 여러 파일이 발견되면 **uuid 기반 중복 제거 후 시간순 병합**하여 처리한다
- 파일이 없거나 실행 실패 시 오류 메시지를 출력하고 Step 7(PKM 업데이트)로 계속 진행한다

### 6-3. 프롬프트 품질 분석

`references/quality-criteria.md`의 5가지 관점(명확성, 컨텍스트, 검증 가능성, 효율성, 재사용성)을 기준으로 각 프롬프트를 평가한다. 각 관점을 높음=2/중간=1/낮음=0으로 채점하여 합산:

- **A등급 (모범)**: 8-10점
- **B등급 (양호)**: 5-7점
- **C등급 (개선 필요)**: 0-4점

각 프롬프트에서 도출할 항목:
- 등급 (A/B/C)
- 원문 전체 (인용 블록으로 포함; 파일 내용 첨부 부분은 `[[파일이름]]` 형태로 축약)
- 의도 요약 (1-2문장)
- Agent 반응 요약 (사용 도구, 결과물)
- 교훈 (잘 된 점 / 개선할 점)

**PKM 노트에 포함할 프롬프트 선택 기준**:
- A등급 전체
- B등급 중 길이 > 50자 또는 많은 도구를 사용한 것
- C등급은 학습 목적으로 1개까지만 포함 가능

단순 확인/승인 응답, 자동 생성된 시스템 메시지는 제외한다.

## 7. PKM 문서 업데이트

PR 생성에 성공한 경우, **반드시** `/pkm` 스킬을 실행하여 PR 노트를 vault에 기록한다.

- 생성된 PR URL을 컨텍스트로 제공하며 `/pkm` 스킬 실행
- pkm 스킬이 PR 제목, 변경사항 요약, 링크를 포함한 노트를 vault에 자동 생성
- Step 6에서 추출한 **Prompt Journal**을 PKM 노트에 함께 포함하여 기록한다:

```markdown
## Prompt Journal

> 이 PR 작업 세션에서 사용된 주요 프롬프트 목록 및 품질 평가

### 세션 통계
- 총 프롬프트 수: N개 (유의미: M개)
- 스킬 호출: K회
- 세션 시간: HH:MM ~ HH:MM (약 N분)

### 주요 프롬프트

#### 🟢 [A등급] 프롬프트 제목 (또는 첫 줄 요약)
> 프롬프트 원문 전체

- **의도**: ...
- **Agent 반응**: Read, Bash 등 사용, 결과물 ...
- **교훈**: 잘 된 점 / 개선할 점

...
```

Step 6 분석 결과가 없으면 Prompt Journal 섹션을 생략한다.

> PR 생성 실패 시에는 이 단계를 건너뛴다.
