---
name: pr-flow
description: Show where the current branch is in the PR flow (preflight, open, steward, triage, restack, merge) and the next command to run. USE WHEN the user asks what to do next with a branch or PR, asks for PR workflow help, or says "pr flow" or "pr next".
---

# PR flow

Run `~/dotfiles/bin/pr-next` and show its output as is. If the user asked for the overview, run `~/dotfiles/bin/pr-next help` instead.

Then offer to run the suggested next step. Do not run it without a yes, unless it is read only (`preflight --list`).

## Shared rules for every pr-* skill

The other skills in this flow (`/preflight`, `/pr-open`, `/pr-triage`, `/pr-steward`, `/pr-stack`, `/pr-sweep`, `/pr-retro`) read this section first.

- **Plan first.** Before running anything, print the plan: the steps and the exact commands. After, print a short summary table.
- **End with the next step.** Finish every run by running `~/dotfiles/bin/pr-next` and printing its `next` line, so the user never has to remember the order.
- **Delegate to repo skills.** If the repo has its own skill for a step (look in `.claude/skills/` and `skills/`, e.g. `jira-ticket-read`, `with-self-code-review`, `code-review`), invoke it rather than redoing its job. This skill adds order; the repo skill adds domain knowledge.
- **Read repo rules, do not assume them.** Read `AGENTS.md` and any review guide (a review guide under `docs/`) for title format, base branch, and review rules.
- **GitHub access.** Use the `gh` CLI. When it is not available (cloud sessions), use the GitHub MCP tools.
- **Never** skip, disable, or quarantine a test. Never force-push a branch you did not create in this session. Never merge a PR; the user presses merge.
- **Show before posting.** Print what you will post to GitHub (comments, PR body, replies) before posting, except under `/pr-steward`, which the user opted into for that PR.
- **Commit messages** follow the repo's convention (commitlint, `type(TICKET): summary`) when it has one, otherwise the user's global rules.
- **Preflight is the user's to start.** It is slow, so no skill runs it unasked. Before a push, check whether HEAD passed (`~/dotfiles/bin/pr-next` says so) and, if not, tell the user to run `preflight` and wait for them, or push only if they say so.
- **Preflight state** lives outside the repo: `~/dotfiles/bin/preflight --manifest` names the manifest, and runs are logged to `~/.local/state/pr-flow/preflight.jsonl`.
