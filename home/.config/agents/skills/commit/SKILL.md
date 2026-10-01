---
name: commit
description: Create commit based on changes
---

Current git status: !`git status`
Recent commits compared to main: !`git log --oneline main..HEAD`
Recent commit style: !`git log --oneline -10`

Create a commit based on the changes. Use local only changes. Do NOT use gh cli for this command.

Message rules (write it in plain English per the rules in ~/.claude/skills/claudish/SKILL.md: no abstractions, metaphors, or filler, just what changed):
- one line, no body
- lowercase, imperative verb first (add, fix, use, remove, update)
- under ~50 chars, no trailing period
- no conventional-commit prefix (`feat:`), no scope, no fluff
- separate unrelated changes with `; `
- examples: `fix tab bar`, `add herdr split navigation`, `use one dark vivid; add nerd font symbols`
