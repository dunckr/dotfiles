---
name: pr-sweep
description: Review all of the user's open PRs in this repo and give each one action - merge approved ones, restack ones behind base, triage unanswered change requests, fill in missing bodies. USE WHEN the user says pr-sweep, asks what state their PRs are in, or as the daily morning routine.
---

# PR sweep

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first. The table goes to the user, never to GitHub.

## Steps

1. List open PRs: `gh pr list --author @me --state open --json number,title,body,headRefName,baseRefName,isDraft,reviewDecision,mergeStateStatus,statusCheckRollup,updatedAt,url`. For each, count unresolved review threads (the graphql query in `/pr-triage`).
2. Flag, in this order of priority:
   - **approved, unmerged**: and how many working days since approval. Over one day is the main thing to fix.
   - **CI red**
   - **changes requested** or unresolved threads with no reply from the user
   - **behind base** or conflicting
   - **no body or no ticket key** in title or body
   - **stale**: no update in five working days
3. Print one table: PR, title, age, state, one action (`gh pr merge <n> --squash`, `/pr-triage <n>`, `/pr-stack`, `/pr-steward <n>`, `/pr-open <n>`, or "waiting on review"). Approved ones go first.
4. Offer to run the actions. Run each only on a yes. Never merge; give the merge command for the user to run.
