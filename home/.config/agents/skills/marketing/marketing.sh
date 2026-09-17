#!/bin/bash
# Fetches coreyhaines31/marketingskills into a cache dir and exposes the
# skills on demand, so none of them live in ~/.claude/skills.
set -euo pipefail

REPO="${MARKETING_SKILLS_REPO:-https://github.com/coreyhaines31/marketingskills.git}"
CACHE="${MARKETING_SKILLS_DIR:-$HOME/.cache/marketingskills}"
SKILLS="$CACHE/skills"

sync() {
  if [[ -d "$CACHE/.git" ]]; then
    if [[ "${1:-}" == "--update" ]]; then
      git -C "$CACHE" pull --quiet --ff-only
      echo "updated $(git -C "$CACHE" rev-parse --short HEAD)"
    fi
  else
    git clone --quiet --depth 1 "$REPO" "$CACHE"
    echo "cloned $(git -C "$CACHE" rev-parse --short HEAD)"
  fi
}

# Prints the frontmatter description of a SKILL.md, single line.
description() {
  awk '
    /^---$/ { fm++; next }
    fm == 1 && /^description:/ { sub(/^description:[ ]*/, ""); gsub(/^"|"$/, ""); print; exit }
  ' "$1"
}

list() {
  sync
  for dir in "$SKILLS"/*/; do
    name="$(basename "$dir")"
    desc="$(description "$dir/SKILL.md" | cut -d. -f1)"
    printf '%-24s %s\n' "$name" "$desc"
  done
}

show() {
  sync
  local file="$SKILLS/$1/SKILL.md"
  if [[ ! -f "$file" ]]; then
    echo "no skill named '$1'. run: marketing.sh list" >&2
    exit 1
  fi
  echo "# skill dir: $SKILLS/$1"
  echo
  cat "$file"
}

path() {
  sync
  echo "$SKILLS/${1:-}"
}

case "${1:-list}" in
  sync)  sync "${2:-}" ;;
  list)  list ;;
  show)  show "${2:?usage: marketing.sh show <name>}" ;;
  path)  path "${2:-}" ;;
  *)     echo "usage: marketing.sh [list | show <name> | path [name] | sync [--update]]" >&2; exit 1 ;;
esac
