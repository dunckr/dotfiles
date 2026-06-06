---
name: pr-comments
description: Fetch Copilot or Claude PR review comments and create a plan to fix them
---

Use your Bash tool to run these commands in sequence:

1. Get current branch: `git branch --show-current`
2. Get repo name: `gh repo view --json nameWithOwner -q .nameWithOwner`
3. Get PR number for this branch: `gh pr list --head <branch> --json number -q '.[0].number'`
4. Fetch inline comments: `gh api repos/<owner/repo>/pulls/<pr-number>/comments`
5. Fetch review summaries: `gh api repos/<owner/repo>/pulls/<pr-number>/reviews`
6. Fetch issue comments (for bot review summaries posted as comments): `gh api repos/<owner/repo>/issues/<pr-number>/comments`

From the comments response, filter to items where `user.login` contains "copilot" or "claude" (case-insensitive). For each, show: file path, line number, and body. For reviews and issue comments, show the body of any Copilot or Claude reviews.

Then:

1. Group related comments by theme (e.g. "wrong request body fields", "weak assertions", "missing script in build chain")
2. For each group, describe what needs to change and which files are affected
3. Present a concise numbered plan — one actionable step per group
4. Ask the user if they want you to implement the fixes

Keep the plan tight: one sentence per step, file paths included.
