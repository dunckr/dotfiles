---
name: preflight
description: Run locally what CI runs, scoped to the packages changed on this branch, before pushing or opening a PR. USE WHEN the user says preflight, asks to check the branch before pushing, or invokes /preflight. Never run it unasked; it is slow.
argument-hint: "[--fix] [--all] [--only name,name]"
---

# Preflight

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first.

The checks are not in this skill. They come from the repo's manifest, found by `~/dotfiles/bin/preflight --manifest`. If there is no manifest, say so, show where it would go (`~/.config/preflight/<repo>.json`), and offer to draft one from the repo's CI workflows. Keep a drafted manifest out of git.

## Steps

1. Print the plan: `~/dotfiles/bin/preflight --list $ARGUMENTS`.
2. Run it: `~/dotfiles/bin/preflight $ARGUMENTS`. Use a long timeout (up to 10 minutes) and run it in the background if it may take longer. It prints a summary and the log path for each failure.
3. For each failure, read its log and fix the cause in the code. Then rerun with `--only <names>` for speed, and finish with a full run, because only a full clean run records HEAD as passed.
   - A check with an `update` command (golden baselines, for example) can be regenerated with `--fix --only <name>`. It commits the regenerated files. Only do this when the diff is an intended change from this branch. If unsure, ask.
   - A failure matching a known-flaky entry has already been rerun once. If it still fails, treat it as real.
   - Non-blocking checks (marked `!`) only warn. Mention them, do not fix them unless asked.
4. Never edit the manifest to make a check pass, and never add to the flaky list without a ticket from the user.

## Done when

`preflight` exits 0. Print the summary, then `~/dotfiles/bin/pr-next` for the next step (usually `/pr-open` or `git push`).
