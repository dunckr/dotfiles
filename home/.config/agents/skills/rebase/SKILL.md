---
name: rebase
description: Rebase the current branch onto origin main (or master) and resolve conflicts
disable-model-invocation: true
---

Current branch: !`git branch --show-current`
Default branch: !`git rev-parse -q --verify origin/main >/dev/null && echo main || echo master`
Git status: !`git status --short`

Rebase the current branch onto the latest default branch (`main`, or `master` if there is no `main`):

1. If the current branch is the default branch, stop and tell the user.
2. `git fetch origin <default>`
3. `git rebase --autostash origin/<default>`
4. For each conflict:
   - Read both sides and the commit being replayed (`git log -1 REBASE_HEAD`) to understand what each change was trying to do.
   - Resolve it so both intents survive. Do not just pick ours or theirs unless one side is clearly obsolete.
   - Lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, etc.): take the default branch version, then regenerate with the project's package manager after the rebase.
   - `git add` the resolved files, then `GIT_EDITOR=true git rebase --continue`.
5. If a conflict is ambiguous (the right answer depends on product intent), stop and ask the user rather than guessing. Never run `git rebase --abort` or `--skip` without asking.
6. After the rebase, run the project's typecheck/lint/tests if they are quick, and fix anything the rebase broke in a new commit.

Do not push. Report the commits replayed, each conflict and how it was resolved, and remind the user a force push (`git push --force-with-lease`) is needed if the branch was already pushed.
