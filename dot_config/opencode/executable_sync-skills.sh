#!/bin/bash
# sync-skills.sh
# ~/.config/agents/skills 하위의 모든 스킬을 opencode가 인식할 수 있도록
# 1-depth 심볼릭 링크로 변환

set -e

AGENTS_SKILLS="$HOME/.config/agents/skills"
OPENCODE_SKILLS="$HOME/.config/opencode/skills"

# 1. 기존 심볼릭 링크 또는 폴더 제거
if [ -L "$OPENCODE_SKILLS" ] || [ -d "$OPENCODE_SKILLS" ]; then
  rm -rf "$OPENCODE_SKILLS"
  echo "Removed existing: $OPENCODE_SKILLS"
fi

# 2. 새 디렉토리 생성
mkdir -p "$OPENCODE_SKILLS"

# 3. 모든 SKILL.md가 있는 폴더에 대해 심볼릭 링크 생성
count=0
find "$AGENTS_SKILLS" -name "SKILL.md" -exec dirname {} \; | sort | while read skill_dir; do
  skill_name=$(basename "$skill_dir")
  
  # 이미 같은 이름이 있으면 경고
  if [ -e "$OPENCODE_SKILLS/$skill_name" ]; then
    echo "⚠️  Skip (duplicate): $skill_name"
    continue
  fi
  
  ln -sf "$skill_dir" "$OPENCODE_SKILLS/$skill_name"
  echo "✅ $skill_name"
done

echo ""
echo "Done! Linked skills:"
ls -1 "$OPENCODE_SKILLS" | wc -l | xargs echo "  Total:"
