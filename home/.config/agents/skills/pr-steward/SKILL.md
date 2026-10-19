---
name: pr-steward
description: Look after one PR until it merges or closes - on CI failure diagnose and push a fix, on review run pr-triage, on conflict merge the base and resolve - with one summary per event. Opt-in per PR. USE WHEN the user says pr-steward or asks Claude to watch, babysit, or drive a PR to green.
argument-hint: "<pr number> (defaults to the current branch's PR)"
---

# PR steward

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first. The user opting in with this command is the permission to push fixes and post triage replies on this one PR without asking each time. It is not permission to merge.

## Start

1. Confirm the PR number and that it is open. Print what the steward will do and will not do (no merge, no force-push, no skipping tests).
2. Subscribe to events:
   - In the Claude desktop app, bind the PR with the PR tools (`bind_pr`) and turn its monitor on, then act on each `<ci-monitor-event>` message.
   - Otherwise, use `/loop` with a self-paced interval, checking `gh pr view <n> --json statusCheckRollup,reviewDecision,mergeStateStatus,state` and unresolved threads each time. Wait about as long as CI takes (10 to 15 minutes), not less.
3. Handle the current state once straight away.

## On each event

- **CI failed.** Get the failing job log (`gh run view <id> --log-failed`). Find the cause. If it is a known-flaky test from the preflight manifest, rerun the job once (`gh run rerun <id> --failed`). If it is the branch's fault, fix it, run only the failing check's command locally (from the manifest, or `preflight --only <name>`), push. If it is not the branch's fault (upstream advisory, infra), post one PR comment saying so and do not push.
- **New review or comments.** Run `/pr-triage <n>`. Design questions go to the user, not GitHub.
- **Conflict or behind base.** Merge `origin/<base>` into the branch (never rebase a pushed branch), resolve, push, and let CI check it. For a stacked branch, use `/pr-stack`.
- **Approved and green.** Tell the user it is ready to merge today with `gh pr merge <n> --squash`. Do not merge.
- **Merged or closed.** Unsubscribe and stop. If other branches were stacked on it, suggest `/pr-stack`.

Each event ends with a one-message summary: what happened, what you did, the commit or comment link, and the `~/dotfiles/bin/pr-next` line.
