---
name: copy-skill
description: >
  GitHub URL의 스킬/플러그인을 분석하여 개선된 버전을 생성하는 스킬.
  구조, 내용 품질, 외부 의존성, 유료→무료 대체, 한글화, 고도화 관점에서
  종합 분석 보고서를 제공하고 사용자 승인 후 개선된 스킬을 생성한다.
  트리거 - 스킬 분석, 스킬 개선, 스킬 복사, copy skill, 스킬 카피,
  이 스킬 개선해줘, GitHub 스킬/플러그인 URL과 함께 분석, 개선, 복사,
  따라 만들어 등을 요청할 때.
---

# Copy Skill

GitHub URL의 스킬/플러그인을 분석하고 개선된 버전을 생성한다.

## 실행 방식 (Subagent 위임)

⚠️ **이 스킬은 토큰 절약을 위해 분석·생성 단계를 subagent에 위임하여 실행한다.** 원본 스킬의 전체 파일 내용이 부모 세션 컨텍스트에 쌓이지 않도록 한다.

### 부모 세션 역할
- URL 수신 및 구조 확인 (단일/멀티 스킬 판별)
- 멀티 스킬인 경우 AskUserQuestion으로 복사 대상 선택
- Subagent 호출·결과 중계
- 분석 보고서 사용자 승인 (AskUserQuestion)
- 최종 완료 보고

### Subagent 위임 흐름

| 단계 | 담당 | 작업 |
|------|------|------|
| Step 1 | 부모 | URL 파싱 + 구조 파악 (SKILL.md 위치로 단일/멀티 판별) |
| Step 1.5 | 부모 | 멀티 스킬이면 AskUserQuestion으로 복사 대상 선택 |
| **Step 2~3** | **Subagent A (general-purpose)** | 전체 파일 수집 + 분석 보고서 작성 → 보고서만 리턴 |
| Step 4 | 부모 | AskUserQuestion으로 보고서 승인 (전체/부분/취소) |
| **Step 5** | **Subagent B (general-purpose)** | 승인된 개선사항 반영하여 새 스킬 생성 + 패키징 → 생성 경로만 리턴 |
| 완료 | 부모 | 생성 결과 요약 보고 |

### 위임 프롬프트 템플릿

**Subagent A** (Step 2~3 분석):
```
GitHub의 스킬/플러그인을 분석해 개선 보고서를 작성해줘.

대상:
- owner: {owner}
- repo: {repo}
- branch: {branch}
- path: {path}  (스킬 루트 경로)
- skill name: {name}

아래 SKILL.md의 Step 2 (전체 파일 수집) + Step 3 (분석 보고서) 절차를 그대로 수행:
~/.config/agents/skills/copy-skill/SKILL.md

참조:
- references/analysis-checklist.md
- references/free-alternatives.md

결과로 "분석 보고서" 마크다운 전문만 리턴해 (수집한 원본 파일 내용은 리턴하지 말고, 보고서에 필요한 요약만 포함).
```

**Subagent B** (Step 5 생성):
```
아래 분석 보고서의 승인된 개선사항을 반영해 새 스킬을 생성해줘.

분석 보고서:
{사용자가 승인한 보고서 전문 + 부분 수정 사항}

원본 스킬 위치:
- owner/{repo}/{path}?ref={branch}

아래 SKILL.md의 Step 5 절차 준수:
~/.config/agents/skills/copy-skill/SKILL.md

수행 순서:
1. init_skill.py로 초기화
2. 의존성 제거/대체
3. 구조 개선 (Progressive Disclosure)
4. 내용 보강, 한글화, 고도화
5. 스크립트 동작 검증
6. package_skill.py로 패키징

결과로 아래만 리턴:
- 생성된 스킬 경로
- 주요 변경사항 3~5줄 요약
- 패키징 성공 여부
- 실패·경고가 있으면 내역
```

**주의**: Subagent는 부모 맥락을 모른다. 승인 단계에서 사용자가 "보고서의 2번 항목만 반영, 3번은 제외" 등 세부 지시를 했다면 Subagent B 프롬프트에 명시적으로 포함한다.

---

## 워크플로우

```
1. URL 수신 → 구조 파악
2. 전체 파일 수집
3. 분석 보고서 작성
4. 사용자 승인
5. 개선된 스킬 생성
```

## Step 1: URL에서 구조 파악

GitHub URL에서 저장소 정보를 추출한다.

### URL 파싱

GitHub URL 형태별 처리:
- `github.com/{owner}/{repo}/tree/{branch}/{path}` → owner, repo, branch, path 추출
- `github.com/{owner}/{repo}` → 루트에서 시작

### 구조 탐색

`gh api` 또는 `WebFetch`로 디렉토리 구조를 재귀 탐색한다.

```bash
# GitHub API로 디렉토리 목록 조회
gh api repos/{owner}/{repo}/contents/{path}?ref={branch} --jq '.[].name'
```

`gh` 인증 실패 시 WebFetch 폴백:
```
WebFetch: https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref={branch}
```

**SKILL.md 위치로 스킬 루트 판단**:
- 현재 경로에 SKILL.md → 단일 스킬, 바로 Step 2로 진행
- `skills/` 하위에 여러 SKILL.md → **멀티 스킬 구조**, Step 1.5로 진행
- SKILL.md 없음 → 비표준 구조, 사용자에게 확인

## Step 1.5: 멀티 스킬 선택 (조건부)

URL 경로에 스킬이 2개 이상 발견되면, `AskUserQuestion` 도구로 사용자에게 복사할 스킬을 선택하게 한다.

각 스킬의 SKILL.md frontmatter에서 `name`과 `description`을 읽어 선택지를 구성한다.

```
AskUserQuestion:
  question: "복사할 스킬을 선택해주세요."
  header: "스킬 선택"
  multiSelect: true   # 여러 스킬 동시 선택 가능
  options:
    - label: "{skill-1-name}"
      description: "{skill-1-description 첫 문장}"
    - label: "{skill-2-name}"
      description: "{skill-2-description 첫 문장}"
    - ...최대 4개, 초과 시 2회로 나누어 질문
```

선택된 스킬만 Step 2 이후 진행한다. 여러 스킬 선택 시 순차적으로 각각 분석 → 승인 → 생성을 반복한다.

## Step 2: 전체 파일 수집

스킬 루트의 모든 파일을 병렬로 읽는다.

```bash
# 파일 내용 조회
gh api repos/{owner}/{repo}/contents/{path}/{file}?ref={branch} \
  --jq '.content' | base64 -d
```

수집 대상:
- `SKILL.md` (필수)
- `scripts/` 내 모든 파일
- `references/` 내 모든 파일
- `assets/` 파일 목록 (바이너리는 목록만)
- 설정 파일 (`package.json`, `requirements.txt` 등)

## Step 3: 분석 보고서 작성

[references/analysis-checklist.md](references/analysis-checklist.md) 체크리스트 기반으로 분석한다.
의존성 분석 시 [references/free-alternatives.md](references/free-alternatives.md) 대체 매핑을 참조한다.

### 보고서 형식

```markdown
# 🔍 스킬 분석 보고서: {스킬명}

## 요약
- **원본**: {GitHub URL}
- **구조**: {표준/비표준}
- **종합 평가**: {상/중/하} — {한 줄 요약}

## 1. 구조 분석
### ✅ 잘된 점
- ...
### 🔧 개선 필요
- ...

## 2. 내용 분석
### ✅ 잘된 점
- ...
### 🔧 개선 필요
- ...

## 3. 의존성 분석
| 현재 의존성 | 유형 | 대체 방안 | 비용 절감 |
|---|---|---|---|
| Gemini API | 유료 API | Claude 빌트인 | ✅ |

## 4. 고도화 제안
- ...

## 5. 한글화/커스터마이징
- ...

## 변경 요약
- 추가: ...
- 수정: ...
- 제거: ...
```

보고서 출력 후 사용자 승인을 요청한다.

## Step 4: 사용자 승인

- **전체 승인** → Step 5
- **부분 수정** → 보고서 조정 후 재확인
- **취소** → 종료

## Step 5: 개선된 스킬 생성

승인된 개선사항을 반영하여 새 스킬을 생성한다.

### 생성 절차

1. `/skill-creator`의 `init_skill.py`로 초기화:
   ```bash
   python3 ~/.claude/skills/skill-creator/scripts/init_skill.py {name} --path {path}
   ```
2. 의존성 제거/대체 (유료 → 무료, 외부 → 빌트인)
3. 구조 개선 (Progressive Disclosure 적용)
4. 내용 보강 (예제, 엣지 케이스, 에러 처리)
5. 한글화 (주석, 설명, 출력)
6. 고도화 (기능 확장, 성능 최적화)
7. 스크립트가 있으면 실행하여 동작 검증
8. `package_skill.py`로 패키징:
   ```bash
   python3 ~/.claude/skills/skill-creator/scripts/package_skill.py {skill-path}
   ```

## 주의사항

- `gh` CLI 인증 실패 시 WebFetch로 GitHub Raw URL 사용
- 바이너리 파일은 원본에서 직접 다운로드
- 원본 스킬의 라이선스를 확인하고 존중
- 분석 보고서는 반드시 사용자 승인 후 생성 진행
