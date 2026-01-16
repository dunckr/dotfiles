#!/bin/bash
set -euo pipefail

# Get absolute path to dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$SCRIPT_DIR"

link() {
  from="$1"
  to="$2"

  # Skip if already correctly linked
  if [[ -L "$to" && "$(readlink "$to")" == "$from" ]]; then
    echo "✓ Already linked: $to"
    return 0
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$to")"

  # Backup existing file if not a symlink
  if [[ -e "$to" && ! -L "$to" ]]; then
    backup="$to.backup.$(date +%s)"
    echo "⚠ Backing up existing file to: $backup"
    mv "$to" "$backup"
  fi

  echo "→ Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

run_if_exists() {
  local script="$1"
  if [[ -f "$DOTFILES/$script" ]]; then
    echo "Running $script..."
    bash "$DOTFILES/$script"
  else
    echo "⚠ Skipping $script (not found)"
  fi
}

run_if_exists "osx/setup.sh"
run_if_exists "homebrew/install.sh"

link "$DOTFILES/home/Brewfile" "$HOME/Brewfile"

if [[ -f "$HOME/Brewfile" ]]; then
  echo "Installing Homebrew packages from Brewfile..."
  brew bundle
fi

run_if_exists "homebrew/language-dependencies.sh"

for location in $(find home -name '.*'); do
  file="${location##*/}"
  file="${file%.sh}"
  link "$DOTFILES/$location" "$HOME/$file"
done

link "$DOTFILES/nvim/init.lua" "$HOME/.config/nvim/init.lua"
link "$DOTFILES/nvim/lua" "$HOME/.config/nvim/lua"
link "$DOTFILES/home/.config/agents/commands" "$HOME/.claude/commands"
link "$DOTFILES/home/.config/agents/settings.json" "$HOME/.claude/settings.json"
