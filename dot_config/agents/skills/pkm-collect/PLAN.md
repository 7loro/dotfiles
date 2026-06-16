# pkm-collect Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 하루 업무 종료 시 Claude Code·Codex 대화 기록을 분석해 기록 가치가 있는 작업만 골라 PKM `source/note/`에 노트로 합성하고, 오늘 일지의 작업 시간대(Morning/Afternoon/Evening)에 백링크를 거는 사용자 레벨 스킬 `pkm-collect`를 만든다.

**Architecture:** 결정론 코어(stdlib-only Python `collect.py`)가 대용량 트랜스크립트(최대 22MB)를 압축 다이제스트(`digest.json`)로 만들고, LLM(`SKILL.md`)이 그 다이제스트만 읽어 작업항목 그룹핑·기록가치 평가·중복 판정·사용자 승인·노트/백링크 작성을 수행한다. 중복은 3층(증분 마커 / `pr_url` frontmatter 매칭 / LLM 주제판정)으로 막는다.

**Tech Stack:** Python 3 (stdlib만: json, re, argparse, pathlib, datetime), Markdown(SKILL.md/config.yaml), unittest(stdlib 테스트). 외부 pip 의존성 없음.

---

## File Structure

```
~/.claude/skills/pkm-collect/
├── SKILL.md                 # LLM 오케스트레이션(6단계). Task 6
├── config.yaml              # 사람/LLM이 읽는 설정 문서. Task 1
├── DESIGN.md                # (작성됨)
├── PLAN.md                  # (이 문서)
├── state.json               # last_run_ts 마커. 런타임 생성(Task 5)
├── scripts/
│   ├── collect.py           # CLI 진입 + 오케스트레이션 + 마커. Task 5
│   ├── claude_digest.py     # Claude 트랜스크립트 → 세션 다이제스트(순수). Task 2
│   ├── codex_digest.py      # Codex history+rollout → 다이제스트(순수). Task 3
│   └── notes_index.py       # source/note frontmatter 인덱스(순수). Task 4
├── references/
│   └── note-template.md     # work-note 구조 레퍼런스. Task 1
└── tests/
    ├── fixtures/            # 샘플 JSONL + 샘플 노트
    ├── test_claude_digest.py
    ├── test_codex_digest.py
    ├── test_notes_index.py
    └── test_collect.py
```

**책임 분리**
- `claude_digest.py` / `codex_digest.py`: 트랜스크립트 1개 → 세션 다이제스트 dict. 파일시스템 외 의존 없음. 단독 테스트.
- `notes_index.py`: vault 노트 frontmatter → 중복 인덱스. 단독 테스트.
- `collect.py`: 위 3개를 묶어 since 마커로 필터·분류·민감제외·출력. CLI.
- `SKILL.md`: digest.json만 입력으로 LLM 판단. Python 내부 모름.

**커밋 규약:** 스킬 폴더를 git으로 관리한다. Task 1에서 init(이미 repo면 그 repo 사용). 모든 commit은 스킬 폴더 기준. 커밋 제목은 한글(type prefix 제외).

---

## Task 1: 스킬 스캐폴드 (config / 템플릿 / git)

**Files:**
- Create: `~/.claude/skills/pkm-collect/config.yaml`
- Create: `~/.claude/skills/pkm-collect/references/note-template.md`
- Create: `~/.claude/skills/pkm-collect/scripts/.gitkeep`
- Create: `~/.claude/skills/pkm-collect/tests/fixtures/.gitkeep`

- [ ] **Step 1: 디렉토리 + git 준비**

Run:
```bash
cd ~/.claude/skills/pkm-collect
mkdir -p scripts references tests/fixtures
touch scripts/.gitkeep tests/fixtures/.gitkeep
git rev-parse --is-inside-work-tree 2>/dev/null || git init
```
Expected: 디렉토리 생성, git 저장소 인식(또는 init).

- [ ] **Step 2: config.yaml 작성**

`config.yaml`:
```yaml
# pkm-collect 설정 — 사람/LLM이 읽고, SKILL.md가 collect.py CLI 인자로 전달한다.
# collect.py는 이 파일을 직접 파싱하지 않는다(stdlib-only 유지).

vault_path: ~/pkm
note_dir: source/note                  # vault 기준 상대
journal_glob: source/journal/{date}.md # {date}=YYYY-MM-DD

# 트랜스크립트 소스
claude_projects: ~/.claude/projects
codex_sessions: ~/.codex/sessions
codex_history: ~/.codex/history.jsonl
include_subagents: false

# 저널 백링크 위치
journal_logs_heading: "## Logs"
journal_time_buckets:                  # 작업항목 대표 시각(로컬) → 시간대
  morning_end: "12:00"                 # 이전 = Morning
  afternoon_end: "18:00"               # 이전 = Afternoon, 이후 = Evening

# 세션 드롭 임계값
thresholds:
  min_prompts: 2
  min_edits: 1
prompt_truncate: 400

# 민감/대상외 제외
exclude:
  keywords: ["의료", "병원", "보험", "건강검진", "진료", "대장내시경"]
  paths: []                            # cwd 경로 부분 매칭(예: 특정 개인 repo)
```

- [ ] **Step 3: references/note-template.md 작성**

`references/note-template.md`:
```markdown
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
```

- [ ] **Step 4: 커밋**

```bash
cd ~/.claude/skills/pkm-collect
git add config.yaml references/note-template.md scripts/.gitkeep tests/fixtures/.gitkeep
git commit -m "chore: pkm-collect 스캐폴드(config·템플릿·디렉토리)"
```

---

## Task 2: claude_digest.py (Claude 트랜스크립트 파서)

**Files:**
- Create: `scripts/claude_digest.py`
- Create: `tests/fixtures/claude_sample.jsonl`
- Test: `tests/test_claude_digest.py`

- [ ] **Step 1: 픽스처 작성**

`tests/fixtures/claude_sample.jsonl` (실제 형식 모사: user 프롬프트 / 노이즈 / Edit / git commit / gh pr create / tool_result PR URL):
```
{"type":"user","userType":"external","timestamp":"2026-06-16T00:30:00.000Z","cwd":"/Users/casper/Workspace/akira-mac","gitBranch":"feat/x","sessionId":"sess-1","message":{"role":"user","content":"<command-name>/clear</command-name>"}}
{"type":"user","userType":"external","timestamp":"2026-06-16T00:31:00.000Z","cwd":"/Users/casper/Workspace/akira-mac","gitBranch":"feat/x","sessionId":"sess-1","message":{"role":"user","content":"전사 정확도 개선해줘"}}
{"type":"assistant","timestamp":"2026-06-16T00:32:00.000Z","sessionId":"sess-1","message":{"role":"assistant","content":[{"type":"tool_use","name":"Edit","input":{"file_path":"lib/stt.dart"}}]}}
{"type":"assistant","timestamp":"2026-06-16T00:33:00.000Z","sessionId":"sess-1","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"git commit -m hello"}}]}}
{"type":"assistant","timestamp":"2026-06-16T00:34:00.000Z","sessionId":"sess-1","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"gh pr create --fill"}}]}}
{"type":"user","userType":"external","timestamp":"2026-06-16T00:35:00.000Z","cwd":"/Users/casper/Workspace/akira-mac","sessionId":"sess-1","message":{"role":"user","content":[{"type":"tool_result","content":"https://github.com/o/r/pull/42 created"}]}}
```

- [ ] **Step 2: 실패 테스트 작성**

`tests/test_claude_digest.py`:
```python
import sys, unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import claude_digest

FIX = Path(__file__).resolve().parent / "fixtures" / "claude_sample.jsonl"


class TestClaudeDigest(unittest.TestCase):
    def setUp(self):
        self.d = claude_digest.parse_claude_transcript(FIX)

    def test_returns_digest(self):
        self.assertIsNotNone(self.d)
        self.assertEqual(self.d["source"], "claude")
        self.assertEqual(self.d["session_id"], "sess-1")
        self.assertEqual(self.d["project"], "akira-mac")

    def test_real_prompt_only(self):
        # 노이즈(<command-name>)는 제외, 실제 프롬프트 1개만
        self.assertEqual(self.d["user_prompts"], ["전사 정확도 개선해줘"])

    def test_edit_and_commit_and_pr(self):
        self.assertIn("lib/stt.dart", self.d["edited_files"])
        self.assertEqual(self.d["commit_count"], 1)
        self.assertTrue(self.d["produced_pr"])
        self.assertEqual(self.d["pr_url"], "https://github.com/o/r/pull/42")

    def test_no_timestamp_returns_none(self):
        import tempfile, os
        fd, p = tempfile.mkstemp(suffix=".jsonl")
        os.write(fd, b'{"type":"user","message":{"role":"user","content":"hi"}}\n')
        os.close(fd)
        self.assertIsNone(claude_digest.parse_claude_transcript(p))
        os.unlink(p)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_claude_digest -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'claude_digest'`

- [ ] **Step 4: claude_digest.py 구현**

`scripts/claude_digest.py`:
```python
#!/usr/bin/env python3
"""Claude Code 트랜스크립트(JSONL) → 세션 다이제스트. stdlib only, 순수 함수."""
from __future__ import annotations
import json
import re
from datetime import datetime
from pathlib import Path

# 실제 유저 프롬프트가 아닌 노이즈 프리픽스(슬래시 커맨드/캐비엇)
_NOISE_PREFIXES = (
    "<local-command-caveat>", "<command-name>", "<command-message>",
    "<command-args>", "Caveat:",
)
_PR_URL_RE = re.compile(r"https?://[^\s)\"']+/pull/\d+")
_GIT_COMMIT_RE = re.compile(r"\bgit\s+commit\b")
_GH_PR_CREATE_RE = re.compile(r"\bgh\s+pr\s+create\b")


def _parse_ts(value):
    """ISO8601(...Z) → 로컬 타임존 aware datetime (실패 시 None)."""
    try:
        dt = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        return None
    return dt.astimezone()


def parse_claude_transcript(path):
    """트랜스크립트 1개 파싱 → 세션 다이제스트 dict. 타임스탬프 없으면 None."""
    path = Path(path)
    user_prompts, edited_files, skills_used, branches = [], set(), set(), set()
    tool_counts, timestamps = {}, []
    commit_count, produced_pr, pr_url, cwd, session_id = 0, False, None, None, None

    with path.open(encoding="utf-8") as fh:
        for raw in fh:
            raw = raw.strip()
            if not raw:
                continue
            try:
                rec = json.loads(raw)
            except json.JSONDecodeError:
                continue

            if rec.get("timestamp"):
                dt = _parse_ts(rec["timestamp"])
                if dt:
                    timestamps.append(dt)
            if rec.get("cwd"):
                cwd = rec["cwd"]
            if rec.get("gitBranch"):
                branches.add(rec["gitBranch"])
            if rec.get("sessionId"):
                session_id = rec["sessionId"]

            typ = rec.get("type")
            msg = rec.get("message") or {}
            content = msg.get("content")

            if typ == "user" and rec.get("userType") == "external":
                if isinstance(content, str):
                    text = content.strip()
                    if text and not text.startswith(_NOISE_PREFIXES):
                        user_prompts.append(text)
                elif isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get("type") == "tool_result":
                            inner = block.get("content")
                            txt = inner if isinstance(inner, str) else json.dumps(inner, ensure_ascii=False)
                            m = _PR_URL_RE.search(txt)
                            # PR URL은 이 세션이 실제로 PR을 생성한 경우(produced_pr=True)에만 채택(링크 출력만 된 경우 오인 방지)
                            if m and not pr_url and produced_pr:
                                pr_url = m.group(0)

            elif typ == "assistant" and isinstance(content, list):
                for block in content:
                    if not isinstance(block, dict) or block.get("type") != "tool_use":
                        continue
                    name = block.get("name", "")
                    tool_counts[name] = tool_counts.get(name, 0) + 1
                    inp = block.get("input") or {}
                    if name in ("Edit", "Write", "NotebookEdit"):
                        fp = inp.get("file_path") or inp.get("notebook_path")
                        if fp:
                            edited_files.add(fp)
                    elif name == "Bash":
                        cmd = str(inp.get("command", ""))
                        if _GIT_COMMIT_RE.search(cmd):
                            commit_count += 1
                        if _GH_PR_CREATE_RE.search(cmd):
                            produced_pr = True
                    elif name == "Skill":
                        sk = str(inp.get("skill") or inp.get("command") or "")
                        if sk:
                            skills_used.add(sk)
                            if "make-pr" in sk:
                                produced_pr = True

    if not timestamps:
        return None
    started, ended = min(timestamps), max(timestamps)
    return {
        "source": "claude",
        "session_id": session_id or path.stem,
        "cwd": cwd,
        "project": Path(cwd).name if cwd else "unknown",
        "branches": sorted(branches),
        "started_at": started.isoformat(),
        "ended_at": ended.isoformat(),
        "duration_min": round((ended - started).total_seconds() / 60, 1),
        "user_prompts": user_prompts,
        "edited_files": sorted(edited_files),
        "commit_count": commit_count,
        "produced_pr": produced_pr,
        "pr_url": pr_url,
        "skills_used": sorted(skills_used),
        "tool_counts": tool_counts,
        "transcript_path": str(path),
    }
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_claude_digest -v`
Expected: PASS (4 tests OK)

- [ ] **Step 6: 커밋**

```bash
cd ~/.claude/skills/pkm-collect
git add scripts/claude_digest.py tests/test_claude_digest.py tests/fixtures/claude_sample.jsonl
git commit -m "feat: Claude 트랜스크립트 다이제스트 파서"
```

---

## Task 3: codex_digest.py (Codex 파서)

> Codex rollout 내부 메시지 포맷은 버전마다 다를 수 있어, **세션 식별·프롬프트는 history.jsonl(안정 포맷)**에서 얻고, **작업 신호(편집파일/PR/cwd)는 rollout 원본을 정규식 스캔**(포맷 비의존)으로 얻는다. rollout 파일명에는 session_id(UUID)가 포함된다(검증됨: `rollout-<ts>-<session_id>.jsonl`).

**Files:**
- Create: `scripts/codex_digest.py`
- Create: `tests/fixtures/codex_history.jsonl`, `tests/fixtures/codex_rollout/rollout-2026-06-16T00-00-00-sessAA.jsonl`
- Test: `tests/test_codex_digest.py`

- [ ] **Step 1: 픽스처 작성**

`tests/fixtures/codex_history.jsonl` (ts=unix; 1781000000 ≈ 2026-06; since 경계 테스트용 1개는 과거):
```
{"session_id":"sessAA","ts":1781000100,"text":"코덱스로 리팩토링 해줘"}
{"session_id":"sessAA","ts":1781000200,"text":"테스트도 추가"}
{"session_id":"sessOLD","ts":1700000000,"text":"옛날 세션(제외돼야 함)"}
```

`tests/fixtures/codex_rollout/rollout-2026-06-16T00-00-00-sessAA.jsonl` (apply_patch 파일 헤더 + cwd + PR URL 포함):
```
{"type":"session_meta","payload":{"cwd":"/Users/casper/Workspace/akira-mac"}}
{"type":"function_call","payload":{"name":"shell","arguments":"apply_patch '*** Begin Patch\n*** Update File: lib/foo.dart\n'"}}
{"type":"event","text":"opened https://github.com/o/r/pull/7"}
```

- [ ] **Step 2: 실패 테스트 작성**

`tests/test_codex_digest.py`:
```python
import sys, unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import codex_digest

FX = Path(__file__).resolve().parent / "fixtures"
HIST = FX / "codex_history.jsonl"
ROLL = FX / "codex_rollout"


class TestCodexDigest(unittest.TestCase):
    def test_history_since_filter(self):
        # since=1781000000 → sessOLD(1700000000) 제외, sessAA만
        sess = codex_digest.load_codex_history(HIST, 1781000000)
        self.assertIn("sessAA", sess)
        self.assertNotIn("sessOLD", sess)
        self.assertEqual(sess["sessAA"]["prompts"], ["코덱스로 리팩토링 해줘", "테스트도 추가"])

    def test_build_digests_signals(self):
        digs = codex_digest.build_codex_digests(HIST, ROLL, 1781000000)
        self.assertEqual(len(digs), 1)
        d = digs[0]
        self.assertEqual(d["source"], "codex")
        self.assertEqual(d["session_id"], "sessAA")
        self.assertEqual(d["project"], "akira-mac")
        self.assertIn("lib/foo.dart", d["edited_files"])
        self.assertTrue(d["produced_pr"])
        self.assertEqual(d["pr_url"], "https://github.com/o/r/pull/7")


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_codex_digest -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'codex_digest'`

- [ ] **Step 4: codex_digest.py 구현**

`scripts/codex_digest.py`:
```python
#!/usr/bin/env python3
"""Codex CLI 세션 → 세션 다이제스트. history.jsonl(프롬프트) + rollout 정규식 스캔(신호)."""
from __future__ import annotations
import json
import re
from datetime import datetime
from pathlib import Path

_PR_URL_RE = re.compile(r"https?://[^\s)\"']+/pull/\d+")
_GH_PR_CREATE_RE = re.compile(r"gh\s+pr\s+create")
_PATCH_FILE_RE = re.compile(r"\*\*\* (?:Add|Update|Delete) File: ([^\\']+)")  # \n'·따옴표 앞에서 멈춤(greedy 오염 방지)
_CWD_RE = re.compile(r'"cwd"\s*:\s*"([^"]+)"')


def load_codex_history(history_path, since_epoch):
    """history.jsonl → {session_id: {prompts, min_ts, max_ts}} (since_epoch 이후만)."""
    sessions = {}
    p = Path(history_path)
    if not p.exists():
        return sessions
    with p.open(encoding="utf-8") as fh:
        for raw in fh:
            raw = raw.strip()
            if not raw:
                continue
            try:
                rec = json.loads(raw)
            except json.JSONDecodeError:
                continue
            sid, ts, text = rec.get("session_id"), rec.get("ts"), rec.get("text")
            if not sid or ts is None or ts < since_epoch:
                continue
            s = sessions.setdefault(sid, {"prompts": [], "min_ts": ts, "max_ts": ts})
            if text:
                s["prompts"].append(text)
            s["min_ts"], s["max_ts"] = min(s["min_ts"], ts), max(s["max_ts"], ts)
    return sessions


def _find_rollout(sessions_dir, session_id):
    base = Path(sessions_dir)
    if not base.exists():
        return None
    for path in base.rglob("*" + session_id + "*.jsonl"):
        return path
    return None


def _scan_rollout(path):
    """rollout 원본 정규식 스캔 → 작업 신호(포맷 비의존)."""
    text = Path(path).read_text(encoding="utf-8", errors="ignore")
    edited = sorted({m.group(1).strip() for m in _PATCH_FILE_RE.finditer(text)})
    pr_url = None
    produced_pr = bool(_GH_PR_CREATE_RE.search(text))
    m = _PR_URL_RE.search(text)
    if m:
        pr_url, produced_pr = m.group(0), True
    cwd_m = _CWD_RE.search(text)
    return {"edited_files": edited, "produced_pr": produced_pr,
            "pr_url": pr_url, "cwd": cwd_m.group(1) if cwd_m else None}


def build_codex_digests(history_path, sessions_dir, since_epoch):
    out = []
    for sid, info in load_codex_history(history_path, since_epoch).items():
        started = datetime.fromtimestamp(info["min_ts"]).astimezone()
        ended = datetime.fromtimestamp(info["max_ts"]).astimezone()
        d = {
            "source": "codex", "session_id": sid, "cwd": None, "project": "unknown",
            "branches": [], "started_at": started.isoformat(), "ended_at": ended.isoformat(),
            "duration_min": round((ended - started).total_seconds() / 60, 1),
            "user_prompts": info["prompts"], "edited_files": [], "commit_count": 0,
            "produced_pr": False, "pr_url": None, "skills_used": [], "tool_counts": {},
            "transcript_path": None,
        }
        rollout = _find_rollout(sessions_dir, sid)
        if rollout:
            sig = _scan_rollout(rollout)
            d["edited_files"] = sig["edited_files"]
            d["produced_pr"] = sig["produced_pr"]
            d["pr_url"] = sig["pr_url"]
            d["transcript_path"] = str(rollout)
            if sig["cwd"]:
                d["cwd"], d["project"] = sig["cwd"], Path(sig["cwd"]).name
        out.append(d)
    return out
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_codex_digest -v`
Expected: PASS (2 tests OK)

- [ ] **Step 6: 실제 Codex 포맷 1회 검증(선택, 신뢰도용)**

Run: `head -3 ~/.codex/sessions/2026/06/16/rollout-*.jsonl | python3 -c "import sys,json;[print(list(json.loads(l).keys())) for l in sys.stdin if l.strip().startswith('{')]" 2>/dev/null | head`
Expected: rollout 라인 키 구조 확인. apply_patch/PR URL 정규식이 실제 데이터에서도 잡히는지 `grep -c 'Update File:' ~/.codex/sessions/2026/06/16/rollout-*.jsonl`로 점검. 안 잡히면 `_PATCH_FILE_RE` 패턴을 실제 포맷에 맞게 보강하고 Step 5 재실행.

- [ ] **Step 7: 커밋**

```bash
cd ~/.claude/skills/pkm-collect
git add scripts/codex_digest.py tests/test_codex_digest.py tests/fixtures/codex_history.jsonl tests/fixtures/codex_rollout/
git commit -m "feat: Codex 세션 다이제스트 파서"
```

---

## Task 4: notes_index.py (중복 인덱스)

**Files:**
- Create: `scripts/notes_index.py`
- Create: `tests/fixtures/notes/PR도큐먼트.md`, `tests/fixtures/notes/일반노트.md`
- Test: `tests/test_notes_index.py`

- [ ] **Step 1: 픽스처 작성**

`tests/fixtures/notes/PR도큐먼트.md`:
```markdown
---
created: 2026-06-16 10:00:00
modified: 2026-06-16 10:00:00
date: 2026-06-16
tags:
  - work
  - fix
pr_url: https://github.com/o/r/pull/42
repository: akira-mac
---

>[!summary]
>- 본문
```

`tests/fixtures/notes/일반노트.md`:
```markdown
---
created: 2026-05-01 09:00:00
modified: 2026-05-01 09:00:00
date: 2026-05-01
tags:
  - personal
---

내용
```

- [ ] **Step 2: 실패 테스트 작성**

`tests/test_notes_index.py`:
```python
import sys, unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import notes_index

NOTES = Path(__file__).resolve().parent / "fixtures" / "notes"


class TestNotesIndex(unittest.TestCase):
    def setUp(self):
        self.idx = notes_index.build_notes_index(NOTES)

    def test_indexes_all_md(self):
        self.assertEqual(len(self.idx), 2)

    def test_pr_fields_parsed(self):
        pr = next(e for e in self.idx if e["title"] == "PR도큐먼트")
        self.assertEqual(pr["pr_url"], "https://github.com/o/r/pull/42")
        self.assertEqual(pr["repository"], "akira-mac")
        self.assertEqual(pr["date"], "2026-06-16")

    def test_non_pr_has_none(self):
        gen = next(e for e in self.idx if e["title"] == "일반노트")
        self.assertIsNone(gen["pr_url"])

    def test_pr_url_set(self):
        self.assertEqual(
            notes_index.pr_url_set(self.idx),
            {"https://github.com/o/r/pull/42"},
        )


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_notes_index -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'notes_index'`

- [ ] **Step 4: notes_index.py 구현**

`scripts/notes_index.py`:
```python
#!/usr/bin/env python3
"""source/note frontmatter 인덱스(중복 감지용). stdlib only."""
from __future__ import annotations
from pathlib import Path


def _read_frontmatter(path):
    """파일 앞 --- ... --- 블록을 top-level key:value dict로 파싱(들여쓰기/리스트 무시)."""
    fm = {}
    try:
        with Path(path).open(encoding="utf-8") as fh:
            if fh.readline().strip() != "---":
                return fm
            for line in fh:
                if line.strip() == "---":
                    break
                if ":" in line and not line[:1].isspace() and not line.startswith("-"):
                    key, _, val = line.partition(":")
                    fm[key.strip()] = val.strip()
    except OSError:
        pass
    return fm


def build_notes_index(note_dir):
    """note_dir/*.md → [{file, title, pr_url, repository, date}]."""
    out = []
    base = Path(note_dir)
    if not base.exists():
        return out
    for path in sorted(base.glob("*.md")):
        fm = _read_frontmatter(path)
        out.append({
            "file": str(path),
            "title": path.stem,
            "pr_url": fm.get("pr_url"),
            "repository": fm.get("repository"),
            "date": fm.get("date"),
        })
    return out


def pr_url_set(index):
    return {e["pr_url"] for e in index if e.get("pr_url")}
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_notes_index -v`
Expected: PASS (4 tests OK)

- [ ] **Step 6: 커밋**

```bash
cd ~/.claude/skills/pkm-collect
git add scripts/notes_index.py tests/test_notes_index.py tests/fixtures/notes/
git commit -m "feat: source/note frontmatter 중복 인덱스"
```

---

## Task 5: collect.py (오케스트레이션 + 마커 + CLI)

**Files:**
- Create: `scripts/collect.py`
- Test: `tests/test_collect.py`

- [ ] **Step 1: 실패 테스트 작성**

`tests/test_collect.py` (헬퍼 함수 단위 + 마커):
```python
import sys, json, tempfile, unittest
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import collect


class TestCollectHelpers(unittest.TestCase):
    def test_classify_substantial_by_edit(self):
        d = {"edited_files": ["a"], "user_prompts": [], "produced_pr": False, "commit_count": 0}
        self.assertEqual(collect.classify(d, min_prompts=2, min_edits=1), "substantial")

    def test_classify_trivial(self):
        d = {"edited_files": [], "user_prompts": ["hi"], "produced_pr": False, "commit_count": 0}
        self.assertEqual(collect.classify(d, min_prompts=2, min_edits=1), "trivial")

    def test_classify_borderline(self):
        d = {"edited_files": [], "user_prompts": ["a", "b"], "produced_pr": False, "commit_count": 0}
        self.assertEqual(collect.classify(d, min_prompts=2, min_edits=1), "borderline")

    def test_sensitive_keyword(self):
        d = {"user_prompts": ["대장내시경 결과 정리"], "cwd": "/x"}
        self.assertTrue(collect.is_sensitive(d, ["대장내시경"], []))

    def test_sensitive_path(self):
        d = {"user_prompts": ["일반"], "cwd": "/Users/casper/private-repo"}
        self.assertTrue(collect.is_sensitive(d, [], ["private-repo"]))

    def test_resolve_since_marker(self):
        fd, p = tempfile.mkstemp(suffix=".json")
        Path(p).write_text(json.dumps({"last_run_ts": "2026-06-16T09:00:00+09:00"}))
        since = collect.resolve_since(p, None)
        self.assertEqual(since.hour, 9)
        Path(p).unlink()

    def test_resolve_since_fallback_midnight(self):
        since = collect.resolve_since("/nonexistent/marker.json", None)
        self.assertEqual((since.hour, since.minute, since.second), (0, 0, 0))


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_collect -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'collect'`

- [ ] **Step 3: collect.py 구현**

`scripts/collect.py`:
```python
#!/usr/bin/env python3
"""pkm-collect 수집기: Claude+Codex → digest.json(stdout). stdlib only.

SKILL.md이 config.yaml 값을 CLI 인자로 전달해 호출한다.
"""
from __future__ import annotations
import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import claude_digest
import codex_digest
import notes_index

DEFAULT_EXCLUDE_KEYWORDS = ["의료", "병원", "보험", "건강검진", "진료", "대장내시경"]


def resolve_since(marker_path, explicit_since):
    """since 결정: 명시값 > 마커 > 오늘 00:00(로컬)."""
    if explicit_since:
        return datetime.fromisoformat(explicit_since).astimezone()
    p = Path(marker_path)
    if p.exists():
        try:
            data = json.loads(p.read_text(encoding="utf-8"))
            return datetime.fromisoformat(data["last_run_ts"]).astimezone()
        except (ValueError, KeyError, json.JSONDecodeError):
            pass
    now = datetime.now().astimezone()
    return now.replace(hour=0, minute=0, second=0, microsecond=0)


def classify(digest, min_prompts, min_edits):
    """세션 기록가치 1차 분류(결정론)."""
    if digest["produced_pr"] or digest["commit_count"] or len(digest["edited_files"]) >= min_edits:
        return "substantial"
    if len(digest["user_prompts"]) >= min_prompts:
        return "borderline"
    return "trivial"


def is_sensitive(digest, keywords, paths):
    hay = " ".join(digest.get("user_prompts") or []) + " " + (digest.get("cwd") or "")
    if any(k and k in hay for k in keywords):
        return True
    cwd = digest.get("cwd") or ""
    return any(pp and pp in cwd for pp in paths)


def main(argv=None):
    ap = argparse.ArgumentParser(description="pkm-collect digest builder")
    ap.add_argument("--vault", required=True)
    ap.add_argument("--claude-projects", default=str(Path.home() / ".claude/projects"))
    ap.add_argument("--codex-sessions", default=str(Path.home() / ".codex/sessions"))
    ap.add_argument("--codex-history", default=str(Path.home() / ".codex/history.jsonl"))
    ap.add_argument("--marker", default=str(Path(__file__).resolve().parent.parent / "state.json"))
    ap.add_argument("--since", default=None)
    ap.add_argument("--min-prompts", type=int, default=2)
    ap.add_argument("--min-edits", type=int, default=1)
    ap.add_argument("--prompt-truncate", type=int, default=400)
    ap.add_argument("--exclude-keywords", default=",".join(DEFAULT_EXCLUDE_KEYWORDS))
    ap.add_argument("--exclude-paths", default="")
    ap.add_argument("--include-subagents", action="store_true")
    ap.add_argument("--update-marker", default=None,
                    help="이 ISO 시각으로 마커 저장 후 종료")
    args = ap.parse_args(argv)

    # 마커 갱신 모드
    if args.update_marker:
        Path(args.marker).write_text(
            json.dumps({"last_run_ts": args.update_marker}, ensure_ascii=False, indent=2),
            encoding="utf-8")
        print(json.dumps({"updated_marker": args.update_marker}, ensure_ascii=False))
        return

    since = resolve_since(args.marker, args.since)
    since_epoch = since.timestamp()
    keywords = [k.strip() for k in args.exclude_keywords.split(",") if k.strip()]
    paths = [p.strip() for p in args.exclude_paths.split(",") if p.strip()]

    sessions = []
    proj_root = Path(args.claude_projects)
    if proj_root.exists():
        for jsonl in proj_root.rglob("*.jsonl"):
            if not args.include_subagents and "subagents" in jsonl.parts:
                continue
            try:
                if jsonl.stat().st_mtime < since_epoch:
                    continue
            except OSError:
                continue
            d = claude_digest.parse_claude_transcript(jsonl)
            if d:
                sessions.append(d)

    sessions.extend(codex_digest.build_codex_digests(
        args.codex_history, args.codex_sessions, since_epoch))

    kept = []
    for d in sessions:
        d["user_prompts"] = [p[:args.prompt_truncate] for p in d["user_prompts"]]
        if is_sensitive(d, keywords, paths):
            continue  # 민감 세션은 출력에서 완전 제외(LLM 비노출)
        d["triviality"] = classify(d, args.min_prompts, args.min_edits)
        if d["triviality"] == "trivial":
            continue
        kept.append(d)

    kept.sort(key=lambda x: x["started_at"])

    idx = notes_index.build_notes_index(Path(args.vault) / "source" / "note")
    pr_urls = notes_index.pr_url_set(idx)
    for d in kept:
        d["already_documented"] = bool(d.get("pr_url") and d["pr_url"] in pr_urls)

    today = since.date().isoformat()
    idx_today = [e for e in idx if e.get("date") == today]

    print(json.dumps({
        "generated_at": datetime.now().astimezone().isoformat(),
        "since": since.isoformat(),
        "sessions": kept,
        "existing_notes_index": idx_today,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest tests.test_collect -v`
Expected: PASS (7 tests OK)

- [ ] **Step 5: 전체 테스트 스위트 확인**

Run: `cd ~/.claude/skills/pkm-collect && python3 -m unittest discover -s tests -p 'test_*.py' -v`
Expected: PASS (총 17 tests OK)

- [ ] **Step 6: 스모크 — 실제 데이터로 실행(작성 없음)**

Run: `cd ~/.claude/skills/pkm-collect && python3 scripts/collect.py --vault ~/pkm --since 2026-06-16T00:00:00+09:00 | python3 -c "import sys,json; d=json.load(sys.stdin); print('sessions:', len(d['sessions']), '| today_notes:', len(d['existing_notes_index']))"`
Expected: 정상 JSON, sessions 수 출력(에러 없이). 민감 키워드 세션이 빠졌는지 육안 확인.

- [ ] **Step 7: 커밋**

```bash
cd ~/.claude/skills/pkm-collect
git add scripts/collect.py tests/test_collect.py
git commit -m "feat: 수집 오케스트레이션·마커·CLI(collect.py)"
```

---

## Task 6: SKILL.md (LLM 오케스트레이션)

**Files:**
- Create: `~/.claude/skills/pkm-collect/SKILL.md`

- [ ] **Step 1: SKILL.md 작성**

`SKILL.md` (frontmatter + 6단계 절차. 트리거 키워드 명시):
````markdown
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
````

- [ ] **Step 2: SKILL.md 로드 검증**

Run: `python3 -c "import re,sys; t=open('/Users/casper/.claude/skills/pkm-collect/SKILL.md').read(); fm=t.split('---')[1]; assert 'name: pkm-collect' in fm and 'description:' in fm; print('frontmatter OK')"`
Expected: `frontmatter OK`

- [ ] **Step 3: 커밋**

```bash
cd ~/.claude/skills/pkm-collect
git add SKILL.md
git commit -m "feat: pkm-collect SKILL.md 오케스트레이션"
```

---

## Task 7: 실데이터 통합 검증 (dry-run, 작성 직전까지)

**Files:** (없음 — 검증 전용)

- [ ] **Step 1: collect 실행 → 선정 가능한 다이제스트 확인**

Run:
```bash
cd ~/.claude/skills/pkm-collect
python3 scripts/collect.py --vault ~/pkm --since 2026-06-16T00:00:00+09:00 \
  | python3 -c "import sys,json; d=json.load(sys.stdin); [print(s['source'], s['project'], s['triviality'], 'PR중복' if s.get('already_documented') else '', '|', (s['user_prompts'][0][:40] if s['user_prompts'] else '')) for s in d['sessions']]"
```
Expected: 오늘 작업한 프로젝트별 세션이 한 줄씩. PR 세션은 `PR중복` 표시. 의료/민감 세션 미노출.

- [ ] **Step 2: 중복 제거 정확성 점검**

Run: `python3 scripts/collect.py --vault ~/pkm --since 2026-06-16T00:00:00+09:00 | python3 -c "import sys,json; d=json.load(sys.stdin); print('today existing notes:', [e['title'] for e in d['existing_notes_index']])"`
Expected: 오늘 make-pr 등으로 이미 생성된 노트 제목 목록. 이 노트들과 겹치는 세션은 4단계에서 SKIP되어야 함을 확인.

- [ ] **Step 3: 멱등성 점검(마커)**

Run:
```bash
cd ~/.claude/skills/pkm-collect
python3 scripts/collect.py --vault ~/pkm --update-marker "2026-06-16T23:59:00+09:00"
python3 scripts/collect.py --vault ~/pkm | python3 -c "import sys,json; print('after-marker sessions:', len(json.load(sys.stdin)['sessions']))"
# 정리: 테스트용 마커 삭제(실사용 첫 실행이 오늘 00:00부터 잡히도록)
rm -f state.json
```
Expected: 마커 이후로 세션 수가 0 근처로 줄어듦 → 증분 동작 확인. 이후 state.json 삭제로 초기화.

- [ ] **Step 4: 최종 커밋(있으면)**

```bash
cd ~/.claude/skills/pkm-collect
git add -A && git commit -m "test: 실데이터 통합 검증" --allow-empty
```

---

## Self-Review

**Spec coverage (DESIGN.md → Task 매핑)**
- §3 데이터 소스 → Task 2(Claude)/3(Codex)
- §4 파이프라인 0~6 → 0~1 collect.py(Task5)/2~4 SKILL.md(Task6)/5 SKILL.md/6 collect --update-marker
- §6 digest 스키마 → Task 2/3/5 출력 dict
- §7 중복 3층 → 증분(Task5 resolve_since)·PR매칭(Task4+5 already_documented)·주제(Task6 SKILL)
- §8 출력 포맷 → Task1 note-template + Task6 작성/백링크 절차
- §9 config → Task1
- §10 엣지/안전 → Task5(민감 제외·mtime), Task6(mktemp `>|`·전체읽기 금지·stub)
- §11 결정(ingest 비트리거) → Task6 전제에 명시
- §12 테스트 → Task2~5 unittest + Task7 통합

**Placeholder scan:** 모든 코드 스텝에 완전한 코드 포함. "TODO/적절히 처리" 없음.

**Type consistency:** 세션 다이제스트 dict 키(source/session_id/project/branches/started_at/ended_at/duration_min/user_prompts/edited_files/commit_count/produced_pr/pr_url/skills_used/tool_counts/transcript_path)를 Claude·Codex 양쪽에서 동일하게 사용. collect.py가 추가하는 키: triviality, already_documented. notes_index 엔트리 키(file/title/pr_url/repository/date) 일관.
