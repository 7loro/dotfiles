#!/usr/bin/env zsh
# chezmoi-add-skills.sh
# ~/.config/agents/skills 내 파일을 chezmoi에 등록하는 스크립트
# venv, 캐시, 민감 정보(API 키, 토큰 등)를 자동 제외
#
# 사용법:
#   ./scripts/chezmoi-add-skills.sh          # dry-run (미리보기)
#   ./scripts/chezmoi-add-skills.sh --apply  # 실제 등록

set -euo pipefail

SKILLS_DIR="$HOME/.config/agents/skills"
DRY_RUN=true
[[ "${1:-}" == "--apply" ]] && DRY_RUN=false

# --- 색상/스타일 ---

BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'

# --- 임시 파일 (정리 보장) ---

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

ADDED_FILE="$TMP_DIR/added"
TRACKED_FILE="$TMP_DIR/tracked"
SECRET_FILE="$TMP_DIR/secret"
PATTERN_FILE="$TMP_DIR/pattern"
touch "$ADDED_FILE" "$TRACKED_FILE" "$SECRET_FILE" "$PATTERN_FILE"

skipped_dir=0

# --- 제외 규칙 ---

EXCLUDE_DIRS=("__pycache__" "venv" ".venv" "node_modules" ".claude" ".git")
EXCLUDE_EXTS=("pyc" "pyo" "lock")
EXCLUDE_FILENAMES=(".env" ".DS_Store")

SECRET_PATTERNS=(
    '"token":' '"refresh_token":' '"client_secret":'
    '"apiKey":' '"api_key":' '"access_token":'
    '"secret_key":' '"private_key":'
    'api_key:' 'secret_key:' 'access_token:' 'private_key:'
)

SAFE_FILENAMES=("config-sample.yaml" "accounts.default.yaml")

# --- 함수 ---

is_excluded_dir() {
    local path="$1"
    for dir in "${EXCLUDE_DIRS[@]}"; do
        [[ "$path" == *"/$dir/"* || "$path" == *"/$dir" ]] && return 0
    done
    return 1
}

is_excluded_ext() {
    local ext="${1##*.}"
    for e in "${EXCLUDE_EXTS[@]}"; do
        [[ "$ext" == "$e" ]] && return 0
    done
    return 1
}

is_excluded_filename() {
    local filename="${1:t}"
    for name in "${EXCLUDE_FILENAMES[@]}"; do
        [[ "$filename" == "$name" ]] && return 0
    done
    [[ "$filename" == .env.* ]] && return 0
    return 1
}

is_safe_file() {
    local filename="${1:t}"
    for name in "${SAFE_FILENAMES[@]}"; do
        [[ "$filename" == "$name" ]] && return 0
    done
    grep -qE '(YOUR_|PLACEHOLDER|<your-|example\.com|your-.*@)' "$1" 2>/dev/null && return 0
    return 1
}

contains_secret() {
    local file="$1"
    file "$file" | grep -q "binary" && return 1
    is_safe_file "$file" && return 1
    for pattern in "${SECRET_PATTERNS[@]}"; do
        grep -q "$pattern" "$file" 2>/dev/null && return 0
    done
    return 1
}

repeat_char() {
    printf '%*s' "$2" '' | tr ' ' "$1"
}

# --- 헤더 ---

echo ""
if $DRY_RUN; then
    print -P "  %B%F{cyan}━━━ chezmoi skills 등록 ━━━%f%b  %F{yellow}%Bdry-run%b%f"
else
    print -P "  %B%F{cyan}━━━ chezmoi skills 등록 ━━━%f%b  %F{green}%Bapply%b%f"
fi
print -P "  %F{8}${SKILLS_DIR}%f"
echo ""

# chezmoi managed 캐시
managed_files=$(chezmoi managed --path-style absolute 2>/dev/null || true)
is_managed() { echo "$managed_files" | grep -qF "$1"; }

# 스킬 수 카운트
total_skills=0
for d in "$SKILLS_DIR"/*/; do
    [[ -d "$d" ]] || continue
    [[ "${d:t}" == ".claude" ]] && continue
    total_skills=$((total_skills + 1))
done
print -P "  %F{8}스킬 스캔 중...%f %B${total_skills}%b개 발견"

# 파일 순회 및 분류
while IFS= read -r -d '' file; do
    rel_path="${file#$SKILLS_DIR/}"
    skill="${rel_path%%/*}"
    file_in_skill="${rel_path#$skill/}"

    if is_excluded_dir "$file"; then
        skipped_dir=$((skipped_dir + 1))
        continue
    fi
    if is_excluded_ext "$file"; then
        echo "$rel_path" >> "$PATTERN_FILE"
        continue
    fi
    if is_excluded_filename "$file"; then
        echo "$rel_path" >> "$PATTERN_FILE"
        continue
    fi
    if contains_secret "$file"; then
        echo "$rel_path" >> "$SECRET_FILE"
        continue
    fi
    if is_managed "$file"; then
        echo "$skill" >> "$TRACKED_FILE"
        continue
    fi

    printf '%s\t%s\n' "$skill" "$file_in_skill" >> "$ADDED_FILE"
    if ! $DRY_RUN; then
        chezmoi add "$file"
    fi

done < <(find "$SKILLS_DIR" -type f -print0 2>/dev/null | sort -z)

# --- 결과 출력 ---

echo ""

added_count=$(wc -l < "$ADDED_FILE" | tr -d ' ')
tracked_total=$(wc -l < "$TRACKED_FILE" | tr -d ' ')
secret_count=$(wc -l < "$SECRET_FILE" | tr -d ' ')
pattern_count=$(wc -l < "$PATTERN_FILE" | tr -d ' ')

# 1) 새로 추가할 파일 (스킬별 그룹)
if [[ $added_count -gt 0 ]]; then
    if $DRY_RUN; then
        print -P "  %F{green}%B+ 추가 예정%b%f %F{8}(${added_count}개 파일)%f"
    else
        print -P "  %F{green}%B+ 추가 완료%b%f %F{8}(${added_count}개 파일)%f"
    fi
    print -P "  %F{8}$(repeat_char '─' 52)%f"

    prev_skill=""
    while IFS=$'\t' read -r skill f; do
        if [[ "$skill" != "$prev_skill" ]]; then
            skill_file_count=$(grep -c "^${skill}	" "$ADDED_FILE" || true)
            [[ -n "$prev_skill" ]] && echo ""
            print -P "  %F{green}◆%f %B${skill}%b %F{8}(${skill_file_count}개)%f"
            prev_skill="$skill"
        fi
        print -P "    %F{8}└─%f ${f}"
    done < <(sort "$ADDED_FILE")
    echo ""
fi

# 2) 이미 등록된 스킬
if [[ $tracked_total -gt 0 ]]; then
    tracked_skills=$(sort "$TRACKED_FILE" | uniq -c | sort -rn)
    tracked_skill_count=$(echo "$tracked_skills" | wc -l | tr -d ' ')

    print -P "  %F{blue}%B✓ 이미 등록됨%b%f %F{8}(${tracked_total}개 파일, ${tracked_skill_count}개 스킬)%f"
    print -P "  %F{8}$(repeat_char '─' 52)%f"

    while read -r count skill; do
        bar_len=$(( count / 3 + 1 ))
        [[ $bar_len -gt 20 ]] && bar_len=20
        bar=$(repeat_char '█' "$bar_len")
        printf "    ${BLUE}✓${NC} %-28s ${BLUE}%s${NC} ${DIM}%s${NC}\n" "$skill" "$bar" "$count"
    done <<< "$tracked_skills"
    echo ""
fi

# 3) 민감 정보 제외
if [[ $secret_count -gt 0 ]]; then
    print -P "  %F{red}%B✗ 민감 정보 제외%b%f %F{8}(${secret_count}개 — API 키, 토큰 등)%f"
    print -P "  %F{8}$(repeat_char '─' 52)%f"
    while read -r f; do
        print -P "    %F{red}✗%f %F{8}${f}%f"
    done < "$SECRET_FILE"
    echo ""
fi

# 4) 패턴 제외
if [[ $pattern_count -gt 0 ]]; then
    print -P "  %F{yellow}%B⊘ 패턴 제외%b%f %F{8}(${pattern_count}개 — *.lock, .env 등)%f"
    print -P "  %F{8}$(repeat_char '─' 52)%f"
    while read -r f; do
        print -P "    %F{yellow}⊘%f %F{8}${f}%f"
    done < "$PATTERN_FILE"
    echo ""
fi

# --- 최종 요약 ---

new_skill_count=0
[[ $added_count -gt 0 ]] && new_skill_count=$(cut -f1 "$ADDED_FILE" | sort -u | wc -l | tr -d ' ')
tracked_skill_unique=0
[[ $tracked_total -gt 0 ]] && tracked_skill_unique=$(sort -u "$TRACKED_FILE" | wc -l | tr -d ' ')

echo ""
print -P "  %B%F{cyan}━━━ 요약 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f%b"
printf "    ${GREEN}+ 추가${NC}      %4s개 파일  ${DIM}(%s개 스킬)${NC}\n" "$added_count" "$new_skill_count"
printf "    ${BLUE}✓ 등록됨${NC}    %4s개 파일  ${DIM}(%s개 스킬)${NC}\n" "$tracked_total" "$tracked_skill_unique"
printf "    ${RED}✗ 민감${NC}      %4s개 파일\n" "$secret_count"
printf "    ${YELLOW}⊘ 패턴${NC}      %4s개 파일\n" "$pattern_count"
printf "    ${DIM}⊘ 디렉토리   %4s개 항목${NC}\n" "$skipped_dir"
print -P "  %F{cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f"

if $DRY_RUN && [[ $added_count -gt 0 ]]; then
    echo ""
    print -P "  %F{yellow}▸%f 실제 등록하려면: %B$0 --apply%b"
fi

echo ""
