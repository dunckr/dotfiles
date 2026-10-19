---
name: pr-retro
description: Measure the last 30 days of the user's PRs in this repo (merged vs abandoned, abandoned lines, thread resolution at merge, CI reruns, time from approval to merge, pushes made without preflight) and append a dated table to the retro log. USE WHEN the user says pr-retro or asks how their PR workflow is trending.
argument-hint: "[days, default 30]"
---

# PR retro

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first.

Log file: `~/.local/state/pr-flow/retro-<repo>.md` (outside git). Create it with a heading if missing. Read the previous entry so you can show the trend.

## Collect (window: last $ARGUMENTS days, default 30)

- PRs by the user created in the window: `gh pr list --author @me --state all --search "created:>=YYYY-MM-DD" --limit 200 --json number,title,body,state,additions,deletions,createdAt,mergedAt,closedAt,headRefName,reviewDecision`.
- Per merged PR: review threads and whether each was resolved or had a reply from the user at merge time; the last human review state before merge; approval time (`gh api repos/O/R/pulls/N/reviews`) to merge time.
- CI pushes per PR: count `synchronize` events or commits after the PR opened, and failed-then-passed runs (`gh run list --branch <b> --json conclusion,headSha`).
- Preflight: `~/.local/state/pr-flow/preflight.jsonl` for runs in the window, and flaky reruns. A pushed PR head sha with no `passed` entry is a push made without preflight.
- Same-ticket re-attempts: more than one PR with the same ticket key where an earlier one closed unmerged.

## Report

Append a section `## YYYY-MM-DD (last N days)` with a table of: PRs opened, merged, closed unmerged; lines in abandoned PRs; threads replied or resolved at merge (%); PRs needing a push only for golden baselines; PRs blocked by a known-flaky test; PRs with no body or ticket key; approved PRs unmerged after one working day; PRs merged with changes requested as the last human state; same-ticket re-attempts; pushes made without preflight. Add a column comparing to the previous entry. Below it, at most three lines on what moved and why.

Print the table to the user too, then name the single worst metric and the skill that addresses it.
