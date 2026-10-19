---
name: pr-stack
description: Restack a chain of dependent branches after a lower branch merges - merge each new base into the branch above in order, push, and retarget PRs whose base merged. USE WHEN the user says pr-stack, restack, or a branch is behind its parent branch or epic branch.
argument-hint: "[top branch of the stack, defaults to current]"
---

# PR stack

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first.

## Steps

1. **Read the stack.** Start from the current (or given) branch and walk down using each open PR's base branch (`gh pr list --author @me --state open --json number,headRefName,baseRefName,state`) until you reach the repo's default branch. Also list merged PRs for those branches (`--state merged`) to find bases that have merged. Print the stack bottom to top with each PR's state.
2. **Plan.** For each branch from the bottom up:
   - If its base PR merged, the new base is that PR's base (often the epic branch or `develop`). It will be retargeted.
   - Otherwise its base stays the same.
   Print the merges, pushes, and `gh pr edit --base` calls you will make, and wait for a yes.
3. **Execute** bottom to top, one branch at a time:
   ```bash
   git fetch origin
   git switch <branch> && git merge --no-edit origin/<new base>
   ```
   Resolve conflicts (keep both sides' intent, ask if unclear), `git push`, and let CI check it. Say which branches have not passed preflight so the user can run it. Then `gh pr edit <n> --base <new base>` if it changed. Merge, never rebase: these branches are pushed and reviewed.
4. Stop at the first branch you cannot get green and report why. Do not continue up the stack on a red branch.

## Done when

Every branch in the stack is green against its base. Print a table (branch, PR, base before and after, preflight result, pushed), then `~/dotfiles/bin/pr-next`.
