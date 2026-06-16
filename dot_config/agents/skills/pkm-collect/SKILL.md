---
name: pkm-collect
description: 하루 업무 종료 시 오늘의 Claude Code·Codex 대화 기록을 분석해 기록 가치가 있는 작업만 골라 PKM vault(~/pkm)의 source/note에 노트로 합성하고, 오늘 일지의 작업 시간대(Morning/Afternoon/Evening)에 백링크를 건다. make-pr가 이미 만든 PR 노트 및 기존 노트와 중복되지 않게 한다. 트리거 - "pkm collect", "오늘 한 일 정리", "업무 정리해줘", "하루 작업 노트", "일과 정리", "오늘 작업 기록", "daily collect" 등 하루를 마무리하며 작업을 PKM에 정리해달라는 요청 시.
---

# pkm-collect

오늘 Claude Code·Codex 대화 기록 → PKM 노트 + 일지 백링크. **결정론 수집은 collect.py, 의미 판단·작성은 LLM**.

## 전제
- vault: `~/pkm` (config.yaml의 vault_path). cwd와 무관하게 이 vault에 작성한다.
- ❌ /pkm-ingest를 트리거하지 않는다. source 노트 + 일지 백링크까지만 만든다.
- 작성 전 반드시 **선정안 미리보기 + 사용자 승인**(4단계)을 거친다.

## 절차

### 0. config 로드
`~/.claude/skills/pkm-collect/config.yaml`을 Read. vault_path·exclude·thresholds·time_buckets 확인.

### 1. 수집 (collect.py 실행)
mktemp로 임시 파일을 만들고(zsh noclobber → `>|`) digest를 받는다:
```bash
DIGEST=$(mktemp /tmp/pkm_collect.XXXXXX)
python3 ~/.claude/skills/pkm-collect/scripts/collect.py \
  --vault ~/pkm \
  --exclude-keywords "의료,병원,보험,건강검진,진료,대장내시경" >| "$DIGEST"
echo "$DIGEST"
```
- `--since`를 주지 않으면 state.json 마커(없으면 오늘 00:00)부터 수집한다.
- digest의 `generated_at`을 기억해 둔다(6단계 마커 갱신에 사용).
- digest를 Read. **원본 트랜스크립트는 절대 직접 읽지 않는다**(토큰 폭발 방지).

### 2~3. 작업항목 그룹핑 + 기록가치 평가 + 중복 판정
digest.sessions를 읽고:
- **그룹핑**: 같은 project + 같은/연속 branch + 같은 주제의 세션을 하나의 "작업 항목"으로 묶는다(Claude↔Codex 교차 포함).
- **기록가치**: `triviality=="substantial"` 또는 의미 있는 의사결정/구현/트러블슈팅이면 CREATE 후보. 단순 Q&A·탐색만·중단된 시도는 제외.
- **중복(PR)**: `already_documented==true`(pr_url이 기존 노트에 있음)이거나 `skills_used`에 make-pr가 있으면 → `SKIP(PR중복)`. pr_url이 없어도 produced_pr이고 `existing_notes_index`에 같은 repository의 오늘자 노트가 있으면 SKIP 후보(불확실하면 4단계에서 사용자 확인).
- **중복(주제)**: `existing_notes_index`(오늘자 노트 제목)와 작업항목 주제가 겹치면 `SKIP(중복)`.

### 4. 선정안 미리보기 + 승인 (필수 게이트)
표로 제시: | 작업항목 | 프로젝트 | 시각 | 액션(CREATE/SKIP사유) | 제안 노트 제목 |
사용자가 항목 추가·제외·제목 수정·승인. **승인 전 어떤 파일도 쓰지 않는다.**

### 5. 노트 작성 + 일지 백링크
승인된 CREATE 항목마다:
1. 세부가 필요하면 해당 세션 `transcript_path`를 **타깃 grep/jq로만** 부분 조회(전체 읽기 금지).
2. `references/note-template.md` 구조로 `~/pkm/source/note/<한글 자연어 제목>.md`를 **Write 도구로** 생성.
   - frontmatter: created/modified(`date "+%Y-%m-%d %H:%M:%S"`)/date/tags.
   - tags: project·내용으로 base(work|personal) 1개 + 주제태그(tag.md 허용목록). 업무 repo→work, 개인 dev→personal.
   - 파일명 한글, 영문 케밥케이스 금지. 동명 파일 있으면 제목 보강.
3. 오늘 일지 `~/pkm/source/journal/$(date +%Y-%m-%d).md`에 백링크 추가:
   - 작업항목 대표 시각(started_at의 로컬 시:분)으로 버킷 결정: <12:00 Morning / <18:00 Afternoon / 그 외 Evening.
   - `## Logs` 하위 해당 `### Morning/Afternoon/Evening` 아래에 `- [[노트 제목]]` 추가(Edit 도구).
   - 이미 같은 링크가 있으면 추가하지 않는다(멱등). 해당 시간대 헤딩이 없으면 만든다.
   - 일지 파일이 없으면 daily frontmatter(`tags: [journal/YYYY]`, date, H1 `YYYY-MM-DD Ddd`) + `## Logs`/시간대 헤딩 stub을 만든 뒤 추가.

### 6. 마커 갱신
1단계에서 기억한 generated_at으로 마커를 저장:
```bash
python3 ~/.claude/skills/pkm-collect/scripts/collect.py --vault ~/pkm --update-marker "<generated_at>"
rm -f "$DIGEST"
```
완료 보고: 생성한 노트 목록과 일지 백링크 위치, SKIP한 항목/사유 요약.

## 주의
- 민감(의료/개인) 세션은 collect.py가 digest에서 이미 제외 → LLM에 노출되지 않는다.
- 절대 원본 트랜스크립트 전체를 컨텍스트로 읽지 않는다. digest와 타깃 grep만 사용.
