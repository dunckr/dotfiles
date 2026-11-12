---
name: terminal
description: Open a new Terminal.app window cd'd into the current folder (repo or worktree root)
disable-model-invocation: true
---

Run this and report the folder that was opened:

```bash
dir=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
open -a Terminal "$dir" && echo "$dir"
```
