#!/usr/bin/env bash
# Shared library functions for worktree scripts

# Removes a project path from IntelliJ IDEA's recent projects list
# Usage: remove_from_intellij_recent_projects "/path/to/project"
remove_from_intellij_recent_projects() {
  local project_path="$1"

  # IntelliJ config directory on macOS
  local jetbrains_dir="$HOME/Library/Application Support/JetBrains"

  if [[ ! -d "$jetbrains_dir" ]]; then
    return 0  # No IntelliJ installed, nothing to do
  fi

  # Find all IntelliJ product directories (IntelliJIdea*, GoLand*, etc.)
  local config_files=()
  while IFS= read -r -d '' file; do
    config_files+=("$file")
  done < <(find "$jetbrains_dir" -type f -name "recentProjects.xml" -print0 2>/dev/null)

  if [[ ${#config_files[@]} -eq 0 ]]; then
    return 0  # No recent projects files found
  fi

  # Process each recentProjects.xml file
  for config_file in "${config_files[@]}"; do
    if [[ -f "$config_file" ]]; then
      # Check if the project path exists in the file
      if grep -q "<entry key=\"$project_path\"" "$config_file" 2>/dev/null; then
        echo "  Removing from IntelliJ recent projects: $(basename "$(dirname "$(dirname "$config_file")")")"

        # Create a backup
        cp "$config_file" "$config_file.bak"

        # Remove the entry using sed
        # This removes the entire <entry key="path">...</entry> block
        sed -i '' "/<entry key=\"$(echo "$project_path" | sed 's/\//\\\//g')\"/,/<\/entry>/d" "$config_file"
      fi
    fi
  done
}
