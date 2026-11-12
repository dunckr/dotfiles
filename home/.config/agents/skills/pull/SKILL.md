---
name: pull
description: Pull origin main (or master) into the local main branch
disable-model-invocation: true
---

Current branch: !`git branch --show-current`
Default branch: !`git rev-parse -q --verify origin/main >/dev/null && echo main || echo master`
Worktrees: !`git worktree list`

Update the local default branch (`main`, or `master` if there is no `main`) from origin with a fast-forward only pull:

- If the current branch is the default branch, run `git pull --ff-only origin <default>`.
- If the default branch is checked out in another worktree, run `git -C <that worktree path> pull --ff-only origin <default>`.
- Otherwise run `git fetch origin <default>:<default>` so the current branch is left alone.

If the fast-forward fails because local main has diverged from origin, stop and show the user `git log --oneline origin/<default>..<default>`. Do not merge, rebase, or reset.

Report the range of commits pulled (old sha..new sha) and the commit count.
