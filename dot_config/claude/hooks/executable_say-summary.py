#!/usr/bin/env python3
"""
Stop hook: Claude Code 응답 완료 시 자연스러운 한국어 TTS로 요약 읽기

- macOS say (Apple Intelligence Premium 음성) 우선 사용
- Premium 음성이 없거나 실패 시 edge-tts 폴백
- claude_agent_sdk로 구어체 요약 생성 (CLI 대비 최적화)
- 텍스트 전처리 (코드/URL/마크다운 제거)
- PID 관리로 이전 TTS 중단
- 설정 파일 지원
"""

import asyncio
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import time
import traceback
from datetime import datetime, timedelta
from pathlib import Path

from claude_agent_sdk import (
    AssistantMessage,
    ClaudeAgentOptions,
    ResultMessage,
    TextBlock,
    ThinkingConfigDisabled,
    query,
)

# 상수
SCRIPT_DIR = Path(__file__).parent
CONFIG_PATH = SCRIPT_DIR / "say-summary.conf.json"
PID_FILE = Path("/tmp/say-summary.pid")
AUDIO_FILE = Path("/tmp/say-summary.mp3")
LOG_FILE = Path("/tmp/say-summary-hook.log")
TTS_LOG_FILE = SCRIPT_DIR / "say-summary-log.txt"

# 기본 설정
DEFAULT_CONFIG = {
    "apple_korean_voice": "Jian",       # macOS Premium 한국어 음성 (Apple Intelligence)
    "apple_english_voice": "Ava",       # macOS 영어 음성
    "apple_korean_rate": 180,
    "apple_english_rate": 180,
    "edge_korean_voice": "ko-KR-SunHiNeural",   # edge-tts 폴백 한국어
    "edge_english_voice": "en-US-AriaNeural",   # edge-tts 폴백 영어
    "edge_korean_rate": "-5%",
    "edge_english_rate": "+0%",
    "enabled": True,
}


def log(message: str) -> None:
    """로그 파일에 메시지 기록"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] {message}\n")


def append_tts_log(summary: str, model: str, voice: str, error: str | None = None) -> None:
    """TTS 사용 내역(또는 실패 이유)을 say-summary-log.txt에 기록"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if error:
        # 실패 시: 오류 이유 기록
        entry = f"{timestamp} | FAIL | {model} | {voice} | {error}\n"
    else:
        # 성공 시: 실제 읽은 내용 기록
        entry = f"{timestamp} | OK   | {model} | {voice} | {summary}\n"
    try:
        with open(TTS_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(entry)
    except Exception as e:
        log(f"TTS 로그 기록 실패: {e}\n{traceback.format_exc()}")


LOG_CLEANUP_MARKER = Path("/tmp/say-summary-cleanup-ts")


def cleanup_old_logs() -> None:
    """일주일(7일) 넘은 TTS 로그 항목 삭제 (1일 1회만 실행)"""
    if not TTS_LOG_FILE.exists():
        return

    # 오늘 이미 정리했으면 건너뛰기
    try:
        if LOG_CLEANUP_MARKER.exists():
            last_cleanup = float(LOG_CLEANUP_MARKER.read_text().strip())
            if time.time() - last_cleanup < 86400:  # 24시간
                return
    except Exception:
        pass

    cutoff = datetime.now() - timedelta(days=7)
    try:
        with open(TTS_LOG_FILE, "r", encoding="utf-8") as f:
            lines = f.readlines()

        kept = []
        for line in lines:
            if not line.strip():
                continue
            try:
                # 형식: "2026-02-19 10:30:00 | ..." → 앞 19자가 타임스탬프
                timestamp_str = line[:19]
                entry_time = datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S")
                if entry_time >= cutoff:
                    kept.append(line)
            except Exception:
                # 파싱 실패한 줄은 보존 (포맷이 다른 메모 등)
                kept.append(line)

        with open(TTS_LOG_FILE, "w", encoding="utf-8") as f:
            f.writelines(kept)

        removed = len(lines) - len(kept)
        if removed > 0:
            log(f"TTS 로그 정리: {removed}개 항목 삭제 (7일 초과)")

        # 정리 완료 타임스탬프 기록
        LOG_CLEANUP_MARKER.write_text(str(time.time()))
    except Exception as e:
        log(f"TTS 로그 정리 실패: {e}\n{traceback.format_exc()}")


def load_config() -> dict:
    """설정 파일 로드, 없으면 기본값 사용"""
    config = DEFAULT_CONFIG.copy()
    try:
        if CONFIG_PATH.exists():
            with open(CONFIG_PATH, "r") as f:
                user_config = json.load(f)
            config.update(user_config)
    except Exception as e:
        log(f"설정 파일 로드 실패: {e}\n{traceback.format_exc()}")
    return config


def kill_previous_playback() -> None:
    """이전 재생 프로세스 종료 (프로세스 그룹 단위, SIGKILL 폴백)"""
    try:
        if PID_FILE.exists():
            pid = int(PID_FILE.read_text().strip())
            PID_FILE.unlink(missing_ok=True)
            try:
                # start_new_session=True로 실행했으므로 프로세스 그룹 전체 종료
                pgid = os.getpgid(pid)
                os.killpg(pgid, signal.SIGTERM)
                # 종료 대기 (최대 0.5초)
                for _ in range(5):
                    time.sleep(0.1)
                    try:
                        os.kill(pid, 0)  # 존재 여부 확인
                    except ProcessLookupError:
                        break
                else:
                    # SIGTERM으로 안 죽으면 SIGKILL 강제 종료
                    os.killpg(pgid, signal.SIGKILL)
                log(f"이전 재생 프로세스 종료: PID {pid}")
            except ProcessLookupError:
                pass
    except Exception as e:
        log(f"이전 프로세스 종료 실패: {e}\n{traceback.format_exc()}")


def extract_last_assistant_message(transcript_path: str) -> str | None:
    """트랜스크립트에서 현재 응답(마지막 user 메시지 이후) 어시스턴트 메시지 추출.
    마지막 user 메시지보다 이전 어시스턴트 메시지는 읽지 않아 이전 응답 오독 방지."""
    try:
        with open(transcript_path, "r") as f:
            lines = f.readlines()

        # 마지막 user 메시지 줄 번호 찾기
        last_user_line = -1
        for i, line in enumerate(lines):
            try:
                data = json.loads(line)
                if data.get("message", {}).get("role") == "user":
                    last_user_line = i
            except json.JSONDecodeError:
                continue

        # 마지막 user 메시지 이후 구간에서만 assistant 메시지 탐색
        search_lines = lines[last_user_line + 1:] if last_user_line >= 0 else lines

        for line in reversed(search_lines):
            try:
                data = json.loads(line)
                message = data.get("message", {})

                if message and message.get("role") == "assistant":
                    content = message.get("content", [])
                    text_parts = [
                        item.get("text", "")
                        for item in content
                        if isinstance(item, dict) and item.get("type") == "text"
                    ]
                    full_text = "".join(text_parts)
                    if full_text:
                        return full_text
            except json.JSONDecodeError:
                continue
    except Exception as e:
        log(f"트랜스크립트 읽기 오류: {e}\n{traceback.format_exc()}")
    return None


def preprocess_text(text: str) -> str:
    """TTS에 부적합한 요소 제거"""
    # 코드 블록 제거
    text = re.sub(r"```[\s\S]*?```", "", text)
    # 인라인 코드 → 텍스트만 추출
    text = re.sub(r"`([^`]+)`", r"\1", text)
    # URL 제거
    text = re.sub(r"https?://\S+", "", text)
    # 이미지 마크다운 제거
    text = re.sub(r"!\[.*?\]\(.*?\)", "", text)
    # 링크 마크다운 → 텍스트만
    text = re.sub(r"\[([^\]]+)\]\([^\)]+\)", r"\1", text)
    # 마크다운 헤더 기호 제거
    text = re.sub(r"^#{1,6}\s+", "", text, flags=re.MULTILINE)
    # 볼드/이탤릭 기호 제거
    text = re.sub(r"\*{1,3}(.*?)\*{1,3}", r"\1", text)
    text = re.sub(r"_{1,3}(.*?)_{1,3}", r"\1", text)
    # 파일 경로 간소화 (/path/to/file.py → file.py)
    text = re.sub(r"(?:/[\w.-]+)+/([\w.-]+)", r"\1", text)
    # 이모지 제거 (TTS가 이름을 읽거나 건너뛰어 어색해짐)
    # 주의: \U000024C2-\U0001F251 범위는 한글 음절(U+AC00~U+D7A3)을 포함하므로
    # 한글 범위를 피해 두 구간으로 분리함
    text = re.sub(
        "["
        "\U0001F300-\U0001F9FF"   # 기호·픽토그램·감정·교통 등
        "\U0001FA00-\U0001FAFF"   # 체스·기타 확장 기호
        "\U00002702-\U000027B0"   # 장식 기호
        "\U000024C2-\U00002701"   # 동그라미 문자 (U+24C2~U+2701)
        "\U0001F1E0-\U0001F251"   # 국기·일본어 기호 등 (U+1F1E0~U+1F251)
        "]+",
        "",
        text,
    )
    # TTS에서 어색하게 읽히는 문장 부호·특수문자 제거
    text = re.sub(r'[!?"\'`~@#$%^*+=\[\]{}]', " ", text)
    # 기타 특수문자 정리
    text = re.sub(r"[<>|&\\]", " ", text)
    # 연속 공백/줄바꿈 정리
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def detect_korean(text: str) -> bool:
    """한국어 포함 여부 확인"""
    for char in text:
        if "\uac00" <= char <= "\ud7a3":
            return True
        if "\u1100" <= char <= "\u11ff":
            return True
    return False


VOICE_CACHE_FILE = Path("/tmp/say-summary-voices.json")
VOICE_CACHE_TTL = 3600  # 1시간


def check_voice_available(voice_name: str) -> bool:
    """특정 say 음성이 시스템에 설치되어 있는지 확인 (캐시 사용)"""
    # 캐시 확인
    try:
        if VOICE_CACHE_FILE.exists():
            cache = json.loads(VOICE_CACHE_FILE.read_text())
            if time.time() - cache.get("ts", 0) < VOICE_CACHE_TTL:
                return voice_name.lower() in cache.get("voices", [])
    except Exception:
        pass

    # 캐시 미스: say -v ? 실행
    try:
        result = subprocess.run(
            ["say", "-v", "?"],
            capture_output=True, text=True, timeout=5,
        )
        voices = [
            line.split()[0].lower()
            for line in result.stdout.splitlines()
            if line.strip()
        ]
        # 캐시 저장
        VOICE_CACHE_FILE.write_text(json.dumps({"ts": time.time(), "voices": voices}))
        return voice_name.lower() in voices
    except Exception as e:
        log(f"음성 목록 확인 실패: {e}\n{traceback.format_exc()}")
    return False


SUMMARY_SYSTEM_PROMPT = (
    "너는 음성 안내 문장을 만드는 역할이야.\n"
    "Claude가 방금 한 작업의 핵심 동작을 자연스러운 한국어 한 문장으로 요약해.\n"
    "\n"
    "규칙:\n"
    "- 10글자 내외(최대 15글자)\n"
    "- 원문을 그대로 인용하지 말고, 어떤 행위를 했는지 동사 중심으로 요약\n"
    "- 자연스러운 한국어 문법의 \"~했어요/~줬어요/~됐어요\" 종결\n"
    "- 영어 단어가 있으면 한국어로 바꿔서 표현\n"
    "\n"
    '좋은 예: "버그 수정했어요", "파일 생성했어요", "인사에 답했어요", "코드 설명했어요", "질문에 답변했어요"\n'
    '나쁜 예: "안녕하세요 무엇을 도와했어요" (원문 짜깁기, 문법 오류)\n'
    '나쁜 예: "로그인 페이지의 인증 버그를 수정했어요" (너무 김)\n'
    '나쁜 예: "안녕하세요했어요" (원문에 종결어미만 붙임)\n'
)


async def _summarize_async(text: str) -> str | None:
    """claude_agent_sdk로 비동기 요약 생성"""
    truncated = text[:1000] if len(text) > 1000 else text

    options = ClaudeAgentOptions(
        model="haiku",
        system_prompt=SUMMARY_SYSTEM_PROMPT,
        tools=[],
        allowed_tools=[],
        max_turns=1,
        thinking=ThinkingConfigDisabled(),
        effort="low",
        env={"SAY_SUMMARY_SKIP": "1"},
    )

    response_text = ""
    async for message in query(
        prompt=f"요약할 텍스트:\n{truncated}",
        options=options,
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    response_text += block.text
        elif isinstance(message, ResultMessage):
            break

    return response_text.strip() if response_text.strip() else None


def summarize_with_sdk(text: str) -> str | None:
    """claude_agent_sdk로 구어체 한 문장 요약 생성"""
    try:
        return asyncio.run(_summarize_async(text))
    except Exception as e:
        log(f"SDK 요약 실패: {e}\n{traceback.format_exc()}")
    return None


def fallback_summary(text: str) -> str:
    """claude CLI 실패 시 규칙 기반 간단 요약 (10글자 내외)"""
    sentences = re.split(r"[.!?\n]", text)
    for sentence in sentences:
        sentence = sentence.strip()
        if len(sentence) > 3:
            if len(sentence) > 15:
                sentence = sentence[:12]
            if not sentence.endswith(("요", "다", "음", "죠")):
                sentence += "했어요"
            return sentence
    return "작업 완료했어요"


def speak_macos_say(text: str, config: dict) -> tuple[bool, str, str | None]:
    """macOS say로 TTS 재생. (성공여부, 음성이름, 실패이유) 반환."""
    is_korean = detect_korean(text)
    voice = config["apple_korean_voice"] if is_korean else config["apple_english_voice"]
    rate = str(config["apple_korean_rate"] if is_korean else config["apple_english_rate"])

    if not check_voice_available(voice):
        reason = f"음성 없음: {voice}"
        log(f"{reason}, edge-tts로 폴백")
        return False, voice, reason

    proc = subprocess.Popen(
        ["say", "-v", voice, "-r", rate, text],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    PID_FILE.write_text(str(proc.pid))
    log(f"macOS say 재생: PID {proc.pid}, 음성={voice}, 속도={rate}")
    return True, voice, None


def speak_edge_tts(text: str, config: dict) -> tuple[bool, str, str | None]:
    """edge-tts로 TTS 재생 (폴백). (성공여부, 음성이름, 실패이유) 반환."""
    is_korean = detect_korean(text)
    voice = config["edge_korean_voice"] if is_korean else config["edge_english_voice"]
    rate = config["edge_korean_rate"] if is_korean else config["edge_english_rate"]

    if not shutil.which("edge-tts"):
        reason = "edge-tts 미설치"
        log(reason)
        return False, voice, reason

    try:
        result = subprocess.run(
            [
                "edge-tts",
                "--voice", voice,
                "--rate", rate,
                "--text", text,
                "--write-media", str(AUDIO_FILE),
            ],
            capture_output=True,
            timeout=10,
        )
        if result.returncode != 0:
            reason = f"edge-tts 종료코드 {result.returncode}: {result.stderr.decode()[:100]}"
            log(f"edge-tts 실패: {result.stderr.decode()}")
            return False, voice, reason
    except subprocess.TimeoutExpired:
        reason = "edge-tts 타임아웃"
        log(f"{reason}\n{traceback.format_exc()}")
        return False, voice, reason
    except Exception as e:
        reason = f"edge-tts 오류: {e}"
        log(f"{reason}\n{traceback.format_exc()}")
        return False, voice, reason

    proc = subprocess.Popen(
        ["afplay", str(AUDIO_FILE)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    PID_FILE.write_text(str(proc.pid))
    log(f"edge-tts 재생: PID {proc.pid}, 음성={voice}, 속도={rate}")
    return True, voice, None


def main() -> None:
    log("=== HOOK 시작 ===")

    # stdin에서 hook 데이터 읽기
    try:
        hook_input = json.loads(sys.stdin.read())
    except Exception as e:
        log(f"stdin 읽기 실패: {e}\n{traceback.format_exc()}")
        return

    # 무한 루프 방지: 요약용 claude CLI가 트리거한 Stop 훅 건너뛰기
    if os.environ.get("SAY_SUMMARY_SKIP") == "1":
        log("SAY_SUMMARY_SKIP=1, 요약용 claude 세션이므로 건너뜀")
        return

    if hook_input.get("stop_hook_active"):
        log("stop_hook_active=True, 건너뜀")
        return

    # 설정 로드
    config = load_config()
    if not config.get("enabled", True):
        log("비활성화 상태")
        return

    # 이전 재생 프로세스 종료
    kill_previous_playback()

    # 트랜스크립트에서 마지막 어시스턴트 메시지 추출
    transcript_path = hook_input.get("transcript_path")
    if not transcript_path:
        log("transcript_path 없음")
        return

    transcript_path = os.path.expanduser(transcript_path)

    # transcript 기록 타이밍 race condition 대응: 최대 3회 재시도 (0.2초 간격)
    last_message = None
    for attempt in range(3):
        last_message = extract_last_assistant_message(transcript_path)
        if last_message:
            break
        if attempt < 2:
            log(f"어시스턴트 메시지 없음, {attempt + 1}번째 재시도 중... (0.2초 대기)")
            time.sleep(0.2)

    if not last_message:
        log("어시스턴트 메시지 없음 (3회 재시도 후 포기)")
        return
    log(f"메시지 길이: {len(last_message)}자")

    # 텍스트 전처리
    cleaned = preprocess_text(last_message)
    if not cleaned or len(cleaned) < 3:
        log(f"전처리 후 텍스트 너무 짧음: {repr(cleaned)}")
        return

    # 이미 짧은 텍스트면 그대로 사용, 아니면 SDK로 요약
    if len(cleaned) <= 15:
        summary = cleaned
    else:
        summary = summarize_with_sdk(cleaned)
        if not summary:
            log("SDK 요약 실패, 규칙 기반 요약 사용")
            summary = fallback_summary(cleaned)

    log(f"최종 요약: {summary}")

    # WezTerm 탭에 🔔 알림 표시 (wezterm CLI로 탭 타이틀 변경)
    try:
        pane_id = os.environ.get("WEZTERM_PANE")
        if pane_id and shutil.which("wezterm"):
            list_result = subprocess.run(
                ["wezterm", "cli", "list", "--format", "json"],
                capture_output=True, text=True, timeout=3,
            )
            panes = json.loads(list_result.stdout)
            tab_id = next(
                (p["tab_id"] for p in panes if str(p.get("pane_id")) == pane_id),
                None,
            )
            if tab_id is not None:
                pane_info = next(
                    (p for p in panes if str(p.get("pane_id")) == pane_id), {}
                )
                # 수동 설정 tab_title 우선, 없으면 프로세스 title 사용
                original = pane_info.get("tab_title") or pane_info.get("title", "")
                # 이미 🔔가 붙어 있으면 중복 방지
                if not original.startswith("🔔"):
                    new_title = f"🔔 {original}" if original else "🔔"
                    subprocess.run(
                        ["wezterm", "cli", "set-tab-title", "--tab-id", str(tab_id), new_title],
                        timeout=3,
                    )
                    log(f"WezTerm 탭 {tab_id}에 🔔 설정: {new_title}")
            else:
                log(f"pane_id={pane_id} 에 해당하는 탭을 찾지 못함")
        else:
            log("WEZTERM_PANE 없거나 wezterm CLI 없음, 탭 알림 건너뜀")
    except Exception as e:
        log(f"WezTerm 탭 알림 설정 실패: {e}\n{traceback.format_exc()}")

    # 1순위: macOS say (Apple Intelligence Premium 음성)
    ok, voice, error = speak_macos_say(summary, config)
    if ok:
        append_tts_log(summary, "apple", voice)
    else:
        append_tts_log(summary, "apple", voice, error)
        # 2순위: edge-tts 폴백
        ok2, voice2, error2 = speak_edge_tts(summary, config)
        if ok2:
            append_tts_log(summary, "edge-tts", voice2)
        else:
            append_tts_log(summary, "edge-tts", voice2, error2)
            log("모든 TTS 실패")

    # 일주일 넘은 로그 정리
    cleanup_old_logs()

    log("=== HOOK 종료 ===")


if __name__ == "__main__":
    main()
