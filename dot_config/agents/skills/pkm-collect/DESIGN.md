# pkm-collect 설계 스펙

> 작성일: 2026-06-16
> 상태: 설계(브레인스토밍) — 사용자 리뷰 대기
> 유형: 사용자 레벨 스킬 (`~/.claude/skills/pkm-collect/`)

## 1. 개요 / 목적

하루 업무를 마친 뒤 호출하면, **오늘 Claude Code / Codex 대화 기록**을 분석해
기록할 가치가 있는 작업들을 골라 **PKM vault(`~/pkm`)의 `source/note/`에 문서 노트로 합성**하고,
**오늘 일간 저널에 백링크**를 걸어 주는 종료(end-of-day) 루틴 스킬.

핵심 제약:
- **make-pr가 이미 만든 PR 노트와 중복 금지** (PR 작업은 재문서화하지 않음)
- **이미 작성된 노트와 중복 금지** (증분 처리 + 주제 중복 판정)
- **모든 대화가 아니라, 기록 가치가 있는 의미 있는 것만**
- Claude뿐 아니라 **Codex 작업도 포함**

## 2. 요구사항 → 충족 매핑

| 사용자 요구 | 충족 방식 |
|---|---|
| 오늘 한 일을 노트로 정리 | 6단계 파이프라인(수집→선정→작성) |
| make-pr PR 노트와 중복 금지 | 2(b) `pr_url`/`repository` frontmatter 매칭 자동 제외 |
| 기존 노트와 중복 금지 | 2(a) 증분 마커 + 2(c) LLM 주제 중복 판정 |
| Codex 작업도 포함 | collect.py가 `~/.codex/sessions/` + `history.jsonl` 파싱 |
| 의미 있는 것만 | 3 사소 세션 드롭 + 기록가치 평가, 4 사용자 검토 게이트 |
| 작업 항목별 개별 노트 | 세션을 논리 작업항목으로 그룹핑, 항목당 노트 1개 |
| 마지막 실행 이후 증분 | `state.json` last_run_ts 마커 |
| 작성 전 검토 | 4 선정안 미리보기 후 사용자 승인 |
| 업무 + 개인 dev 포함 | 대상 범위에 work repo + 개인 dev 포함, 의료/사적 민감 세션 제외 |

## 3. 데이터 소스 (검증된 사실)

### Claude Code
- 경로: `~/.claude/projects/<cwd-경로-인코딩>/<세션UUID>.jsonl` (프로젝트별 폴더, 세션당 JSONL 1개)
- 서브에이전트: `<UUID>/subagents/agent-*.jsonl` (기본 제외, 옵션으로 포함)
- 라인 단위 메타 필드: `cwd`, `gitBranch`, `timestamp`(ISO8601 UTC), `sessionId`,
  `type`(user/assistant/attachment/…), `userType`, `message.role`, `message.content`
- 실제 유저 프롬프트 식별: `type=="user" and userType=="external"` 이면서
  `message.content`가 string인 것. 단 슬래시 커맨드(`<command-name>`),
  `<local-command-caveat>`, tool_result(배열) 은 노이즈로 제외
- 작업 신호: `type=="assistant"`의 `message.content[]` 중 `type=="tool_use"`의 `.name`
  (Edit/Write/Bash/Skill/Agent…). Bash `git commit`·`gh pr create`는 `.input.command` grep
- **파일이 최대 22MB** → 원본을 LLM 컨텍스트에 직접 넣지 않는다 (collect.py가 압축)

### Codex
- 세션: `~/.codex/sessions/YYYY/MM/DD/rollout-<ts>-<uuid>.jsonl` (전체 롤아웃)
- 프롬프트 인덱스: `~/.codex/history.jsonl` — `{session_id, ts(unix), text}` 라인
- rollout JSONL 내부 메시지 포맷은 구현 단계에서 정밀 확인(엔트리 type 분포 점검 후 파서 확정)

## 4. 아키텍처 — 6단계 파이프라인

```
0. config + 마커 로드
   config.yaml: vault 경로, 제외 패턴, 임계값, 백링크 섹션명
   state.json:  last_run_ts (없으면 → 오늘 00:00 로컬)

1. 수집·다이제스트   [scripts/collect.py — 결정론]
   - Claude: ~/.claude/projects/*/*.jsonl  (mtime > last_run_ts)
   - Codex : 오늘 rollout-*.jsonl + history.jsonl
   - 세션별 압축 다이제스트(digest.json) 생성 (스키마 §6)
   - 드롭: 사소(파일편집 0 AND 실제 프롬프트 < 2) / 민감(config 제외 패턴 매칭)

2. 중복 제거   [collect.py(결정론) + LLM]
   (a) 증분 마커: last_run_ts 이후만 → 재실행 중복 차단
   (b) PR 중복: source/note/*.md frontmatter의 pr_url·repository 인덱스 →
       PR 생성 세션(gh pr create 또는 pr_url 캡처)이 인덱스에 있으면 already_documented=true
   (c) 주제 중복: LLM이 같은 날 기존 노트 제목/요약과 작업항목을 대조해 중복 판정

3. 선정·분석   [LLM, SKILL.md 본문]
   - 세션 → 논리 "작업 항목" 그룹핑 (같은 branch/주제 세션은 1항목으로 병합)
   - 기록가치 평가: 구현/의사결정/트러블슈팅/설계 = 가치 O,
     단순 Q&A/탐색만/실패로 끝남 = 가치 X
   - 산출: 선정안 테이블 [작업항목 → CREATE | SKIP(PR중복) | SKIP(사소) | SKIP(중복)]

4. 검토 게이트   [사용자 승인]
   - 선정안 테이블을 사용자에게 제시 (프로젝트·작업요약·액션·근거)
   - 사용자가 승인/수정(항목 추가·제외·제목 변경) 후 진행

5. 노트 작성 + 저널 백링크   [LLM + Write]
   - 승인된 CREATE 항목마다 source/note/<한글 자연어 제목>.md 생성
     · frontmatter: created/modified(YYYY-MM-DD HH:MM:SS)/date/tags
     · tags: 프로젝트·내용으로 work|personal 1개 + 주제 태그 추론 (tag.md 준수)
     · 본문: writing-guide.md work-note 구조 (>[!summary] / 목적 / 작업내용 / 결과 / 참고)
     · 세부 필요 시 해당 세션 transcript를 타깃 grep으로 드릴다운
   - 오늘 저널 source/journal/YYYY-MM-DD.md 의 ## Logs 하위
     ### Morning / ### Afternoon / ### Evening 중 작업 시간대에 맞는 곳에
     `- [[노트제목]]` 백링크 추가 (기존 PR 노트 링크와 동일 컨벤션)
     · 시간대 = 작업항목 대표 시각(세션 시작 또는 주 작업 시각)으로 버킷 매핑
     · 기존 내용 보존 / 이미 있는 링크는 skip(멱등)
   - 저널 파일이 없으면 → daily frontmatter(journal/YYYY·date·H1) + Logs 헤딩 stub 생성 후 추가
   - ❌ ingest(/pkm-ingest)는 트리거하지 않는다 (entity 합성은 평소 흐름에 위임)

6. 마커 갱신   state.json.last_run_ts = now
```

## 5. 구성 요소 (유닛)

| 파일 | 책임 | 의존 |
|---|---|---|
| `SKILL.md` | 오케스트레이션(6단계), LLM 판단 규칙 | collect.py, config |
| `scripts/collect.py` | Claude+Codex JSONL → digest.json (수집·압축·드롭·PR신호) | 파일시스템만 (순수) |
| `scripts/scan_notes.py` | source/note frontmatter 인덱스(pr_url/repository/title/date) | vault 경로 |
| `config.yaml` | vault 경로·제외 패턴·임계값·섹션명 | — |
| `state.json` | last_run_ts 마커 | — |
| `references/note-template.md` | work-note 구조 레퍼런스 | — |

> `scan_notes.py`는 collect.py의 서브명령으로 합쳐도 됨(구현 단계 결정).

각 유닛 경계 점검:
- `collect.py`: 입력=파일경로+마커, 출력=digest.json. transcript 형식만 알면 단독 테스트 가능.
- `SKILL.md`: digest.json + 노트 인덱스를 입력으로 LLM 판단만 수행. 수집 내부 모름.

## 6. digest.json 스키마 (collect.py 출력)

```json
{
  "generated_at": "2026-06-16T19:30:00+09:00",
  "since": "2026-06-16T00:00:00+09:00",
  "sessions": [
    {
      "source": "claude",                  // claude | codex
      "session_id": "664d9f70-…",
      "project": "akira-mac",              // cwd basename 또는 repo명
      "cwd": "/Users/casper/Workspace/akira-mac",
      "branches": ["feat/multi-engine"],
      "started_at": "2026-06-16T09:30:00+09:00",
      "ended_at":   "2026-06-16T10:43:00+09:00",
      "duration_min": 73,
      "user_prompts": ["전사가 정확히 안 되는 경우…", "…"],  // 실제 프롬프트(노이즈 제외), 길면 truncate
      "edited_files": ["lib/foo.dart", "…"],   // Edit/Write 대상 경로
      "commit_count": 3,
      "produced_pr": true,
      "pr_url": "https://github.kakaocorp.com/…/pull/42",  // 캡처되면
      "skills_used": ["make-pr", "make-commit"],
      "tool_counts": {"Edit": 12, "Bash": 30, "Read": 8},
      "triviality": "substantial",        // trivial | borderline | substantial
      "excluded_reason": null             // "sensitive" 등이면 제외 사유
    }
  ],
  "existing_notes_index": [
    {"file": "source/note/…PR21….md", "pr_url": "…/pull/21",
     "repository": "agent-review", "date": "2026-05-28", "title": "…"}
  ]
}
```

## 7. 중복 제거 전략 (3층)

1. **증분 마커** — `last_run_ts` 이후 활동만 수집 → 하루 여러 번 실행해도 중복 없음. 첫 실행은 오늘 00:00.
2. **PR 중복(결정론)** — PR 생성 세션의 `pr_url`(또는 `repository`+branch)이
   `source/note` frontmatter 인덱스에 있으면 자동 `SKIP(PR중복)`.
3. **주제 중복(LLM)** — 같은 날 기존 노트 제목/요약과 작업항목 주제를 대조해 중복이면 `SKIP(중복)`.

> 백링크 추가는 마커와 독립적으로 멱등하게: 노트가 이미 저널에 링크돼 있으면 다시 추가하지 않는다.

## 8. 출력 포맷

### 노트 (source/note/<한글 제목>.md)
- file-creation.md / writing-guide.md / frontmatter.md 준수
- frontmatter: `created`·`modified`(`YYYY-MM-DD HH:MM:SS`)·`date`·`tags`(base 1 + 주제)
- 파일명: 한글 자연어, 공백 허용. 영문 케밥케이스 금지
- 본문: `>[!summary]` → `# 목적` → `# 작업 내용` → `# 결과` → `# 참고`(세션/브랜치/관련 링크)

### 저널 백링크 (source/journal/YYYY-MM-DD.md)
- `## Logs` 하위 `### Morning` / `### Afternoon` / `### Evening` 중
  작업 시간대에 맞는 소제목 아래 `- [[노트제목]]` 추가
- 시간대 버킷: Morning(~12:00) / Afternoon(12:00~18:00) / Evening(18:00~) — 설정 가능
- 작업항목 대표 시각(세션 시작 또는 주 작업 시각)으로 버킷 결정
- 기존 PR 노트 백링크(`- [[ax-product-analysis - PR146 …]]`)와 완전히 동일한 컨벤션
- 기존 내용 보존, 이미 있는 링크는 skip(멱등)
- 참고: 저널의 "Notes created today" base 쿼리에도 자동 노출됨(별개·중복 아님)

## 9. config.yaml 스키마(초안)

```yaml
vault_path: ~/pkm
note_dir: source/note
journal_glob: source/journal/{date}.md      # {date}=YYYY-MM-DD
journal_logs_heading: "## Logs"             # 백링크는 이 하위 시간대 소제목에
journal_time_buckets:                        # 작업항목 대표 시각 → 시간대 버킷
  morning_end: "12:00"                       # 이전 = Morning
  afternoon_end: "18:00"                     # 이전 = Afternoon, 이후 = Evening
claude_projects: ~/.claude/projects
codex_sessions: ~/.codex/sessions
codex_history: ~/.codex/history.jsonl
include_subagents: false
exclude:                                     # 민감/대상외 제외 패턴
  paths: []                                  # cwd 경로 부분 매칭
  keywords: ["의료", "병원", "보험", "건강검진"]  # 프롬프트 매칭 시 제외
thresholds:
  min_prompts: 2
  min_edits: 1
prompt_truncate: 400
```

## 10. 엣지 케이스 / 안전장치

- 대용량 transcript: 절대 LLM이 직접 read 금지. collect.py만 파싱.
- 같은 작업이 여러 세션/도구(Claude→Codex)에 걸침: branch/주제로 1항목 병합.
- PR URL이 tool_result에만 있고 캡처 실패: `repository`+branch 폴백 매칭, 그래도 불확실하면 검토 게이트에서 사용자 확인.
- 저널 파일명/내용 불일치 가능성(learning-log) → date 기준으로 오늘 파일 탐색.
- zsh noclobber·임시파일: mktemp 사용, `>|` 리다이렉트 (learning-log 준수).
- 민감 세션: config exclude 매칭 시 digest 자체에서 제외(LLM에 노출 안 함).
- 노트 작성은 `Write` 도구 사용(긴 노트는 obsidian create보다 안전 — learning-log).

## 11. 결정 사항 / 미해결

- 이름: **pkm-collect** (확정)
- 백링크 위치: 일지 `## Logs`의 Morning/Afternoon/Evening 중 **작업 시간대** (확정)
- 저널 없으면: 최소 stub 생성 (변경 가능 — 대안: 건너뛰고 경고)
- entity 합성/ingest: 이 스킬은 **ingest를 트리거하지 않는다**. source 노트 + 저널 백링크까지만 (확정)
- scan_notes를 collect.py에 합칠지: 구현 단계 결정
- Codex rollout 내부 포맷: 구현 단계 정밀 확인 필요

## 12. 테스트 전략

- collect.py: 샘플 transcript fixture로 단위 테스트(프롬프트 추출/PR신호/드롭 임계값/민감 제외).
- dedup: PR 노트 인덱스 + PR 생성 세션 fixture로 SKIP 판정 검증.
- 멱등성: 같은 입력 2회 실행 시 노트·백링크 중복 생성 0건.
- 통합: 오늘 실제 데이터로 dry-run(작성 직전 선정안까지만) 검증.
