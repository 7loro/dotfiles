#!/bin/bash
# Claude Code Statusline - 멀티라인 상태바
input=$(cat)

# 색상 정의
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
DIM='\033[2m'; GRAY='\033[90m'; MAGENTA='\033[35m'; RESET='\033[0m'

# --- 데이터 추출 ---
MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
DIR_NAME="${DIR##*/}"

# 컨텍스트 윈도우
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
PCT_INT=$(printf "%.0f" "$PCT" 2>/dev/null || echo "0")
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
TOTAL_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# 현재 사용중인 토큰 (used_percentage 기반)
USED_TOKENS=$(awk "BEGIN {printf \"%.0f\", $CTX_SIZE * $PCT / 100}" 2>/dev/null || echo "0")

# 비용 & 시간 (API 제공 값 사용)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# --- 토큰 포맷 함수 ---
format_tokens() {
  local t=${1:-0}
  if [ "$t" -ge 1000000 ] 2>/dev/null; then
    awk "BEGIN {printf \"%.1fM\", $t / 1000000}"
  elif [ "$t" -ge 1000 ] 2>/dev/null; then
    awk "BEGIN {v=$t/1000; if (v >= 100) printf \"%.0fk\", v; else if (v >= 10) printf \"%.0fk\", v; else printf \"%.1fk\", v}"
  else
    echo "${t}"
  fi
}

# --- Git 정보 (5초 캐시) ---
CACHE_FILE="/tmp/claude-statusline-git-cache"
CACHE_MAX_AGE=5

cache_stale() {
  [ ! -f "$CACHE_FILE" ] || \
  [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_stale; then
  if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null || echo "detached")
    STAGED=$(git -C "$DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git -C "$DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
  else
    echo "||" > "$CACHE_FILE"
  fi
fi
IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

# --- 진행바 (색상 코딩, 빈 부분은 점으로) ---
if [ "$PCT_INT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT_INT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

BAR_W=15
FILLED=$((PCT_INT * BAR_W / 100))
EMPTY=$((BAR_W - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '█')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '·')"


# --- Agent 정보 ---
AGENT=$(echo "$input" | jq -r '.agent.name // empty')
AGENT_INFO=""
[ -n "$AGENT" ] && AGENT_INFO=" ${DIM}|${RESET} 🤖 ${MAGENTA}${AGENT}${RESET}"

# --- 마지막 사용자 메시지 (5초 캐시) ---
# transcript 경로: 입력 JSON에서 추출 시도 후 현재 프로젝트 디렉토리 기반으로 탐색
TRANSCRIPT=$(echo "$input" | jq -r '.session.transcript_path // .transcript_path // empty')
if [ -z "$TRANSCRIPT" ]; then
  # 현재 디렉토리를 프로젝트 키로 변환 (앞 슬래시 제거 후 /를 -로 치환)
  DIR_KEY=$(echo "$DIR" | sed 's|^/||; s|/|-|g')
  TRANSCRIPT=$(ls -t ~/.claude/projects/"$DIR_KEY"/sessions/*.jsonl 2>/dev/null | head -1)
fi

# 캐시 파일은 transcript 경로 기반으로 인스턴스별 고유하게 생성
if [ -n "$TRANSCRIPT" ]; then
  CACHE_KEY=$(echo "$TRANSCRIPT" | md5 -q 2>/dev/null || echo "$TRANSCRIPT" | md5sum 2>/dev/null | cut -c1-8)
else
  CACHE_KEY="default"
fi
MSG_CACHE="/tmp/claude-statusline-msg-${CACHE_KEY}"
MSG_CACHE_AGE=5

msg_cache_stale() {
  [ ! -f "$MSG_CACHE" ] || \
  [ $(($(date +%s) - $(stat -f %m "$MSG_CACHE" 2>/dev/null || stat -c %Y "$MSG_CACHE" 2>/dev/null || echo 0))) -gt $MSG_CACHE_AGE ]
}

LAST_MSG=""
if msg_cache_stale; then

  if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
    LAST_MSG=$(jq -rs '
      def is_unhelpful:
        startswith("[Request interrupted") or
        startswith("[Request cancelled") or
        startswith("<") or
        test("^\\s*$");
      [.[] | objects | select(.type == "user") |
       select(.message.content | type == "string" or
              (type == "array" and any(.[]; .type == "text")))] |
      reverse |
      map(.message.content |
          if type == "string" then .
          else [.[] | select(.type == "text") | .text] | join(" ") end |
          gsub("\n"; " ") | gsub("  +"; " ") | gsub("^ +| +$"; "")) |
      map(select(is_unhelpful | not)) |
      first // ""
    ' < "$TRANSCRIPT" 2>/dev/null)
  fi
  echo "$LAST_MSG" > "$MSG_CACHE"
else
  LAST_MSG=$(cat "$MSG_CACHE" 2>/dev/null)
fi

# --- 포맷된 값 ---
USED_K=$(format_tokens "$USED_TOKENS")
CTX_K=$(format_tokens "$CTX_SIZE")
IN_K=$(format_tokens "$TOTAL_IN")
OUT_K=$(format_tokens "$TOTAL_OUT")

# 비용 포맷
if awk "BEGIN {exit !($COST < 0.01 && $COST > 0)}" 2>/dev/null; then
  COST_FMT=$(printf '$%.4f' "$COST")
else
  COST_FMT=$(printf '$%.2f' "$COST")
fi

MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

# --- Git 표시 ---
GIT_INFO=""
if [ -n "$BRANCH" ]; then
  GIT_CHANGES=""
  [ "$STAGED" -gt 0 ] 2>/dev/null && GIT_CHANGES=" ${GREEN}+${STAGED}${RESET}"
  [ "$MODIFIED" -gt 0 ] 2>/dev/null && GIT_CHANGES="${GIT_CHANGES} ${YELLOW}~${MODIFIED}${RESET}"
  GIT_INFO=" ${DIM}|${RESET} 🌿 ${BRANCH}${GIT_CHANGES}"
fi

# === 1줄: 📁 디렉토리 | 🌿 Git | 🧠 모델 | Vim | 🤖 Agent ===
printf "📁 %s" "$DIR_NAME"
printf "%b" "$GIT_INFO"
printf " ${DIM}|${RESET} 🧠 ${CYAN}%s${RESET}" "$MODEL"
printf "%b\n" "$AGENT_INFO"

# === 2줄: 진행바 (토큰) | 💰 비용 | ⏱ 시간 | 📊 누적 입출력 ===
printf "%b%s${RESET} %s%% ${GRAY}(%s/%s)${RESET}" "$BAR_COLOR" "$BAR" "$PCT_INT" "$USED_K" "$CTX_K"
printf " ${DIM}|${RESET} 💰 ${YELLOW}%s${RESET}" "$COST_FMT"
printf " ${DIM}|${RESET} ⏱ %dm %ds" "$MINS" "$SECS"
printf " ${DIM}|${RESET} 📊 ${GRAY}in:%s out:%s${RESET}" "$IN_K" "$OUT_K"
printf "\n"

# === 3줄: 💬 마지막 사용자 메시지 ===
if [ -n "$LAST_MSG" ]; then
  # 터미널 너비에 맞게 자르기 (prefix 💬 + 공백 = 약 4칸)
  TERM_W=$(tput cols 2>/dev/null || echo 80)
  MAX_LEN=$((TERM_W - 5))
  if [ ${#LAST_MSG} -gt $MAX_LEN ]; then
    LAST_MSG="${LAST_MSG:0:$MAX_LEN}…"
  fi
  printf "💬 ${DIM}%s${RESET}\n" "$LAST_MSG"
fi
