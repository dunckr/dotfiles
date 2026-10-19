---
name: pr-open
description: Open (or fix up) a pull request for the current branch with a ticket-derived title and body, after a self review. USE WHEN the user says pr-open, asks to open or raise a PR, or pr-next says the PR has no body or ticket key.
argument-hint: "[pr number to fix up an existing PR]"
---

# PR open

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first.

## Steps

1. **State.** Run `~/dotfiles/bin/pr-next`. If the tree is dirty, stop and ask to commit first. If HEAD has not passed preflight, say so and ask the user to run `preflight` (or confirm to open without it).
2. **Ticket.** Take the key from the branch name (`ABC-123/...`). Read it with the repo's `jira-ticket-read` skill if present, otherwise the Atlassian MCP tools. No key in the branch: ask for one. Do not rename the branch if a PR is already open.
3. **Self review.** Run the repo's `with-self-code-review` skill if present, otherwise the `code-review` skill on the branch diff. Fix what it finds, commit, and tell the user preflight needs rerunning if code changed.
4. **Base branch.** Use the repo's default (from `AGENTS.md`, the review guide, or the manifest `base`). If the branch was cut from another feature or epic branch (check `git log --first-parent`, the epic doc if the repo has one, and `pr-stack` notes), target that branch and say so.
5. **Title and body.** Title in the repo's format, e.g. `feat(ABC-123): summary`. Body:
   - **What**: the change, in two or three lines.
   - **Why**: from the ticket, with the ticket link.
   - **How**: the approach and anything a reviewer should look at first.
   - Testing notes only if they say something preflight does not (manual steps, screenshots).
   Follow any PR template in `.github/`. Keep it short and plain.
   The global rule of an empty PR body applies only to repos with no review guide asking for one. When the repo's guide asks for a description and ticket link, the repo wins.
6. **Show** the title, body, base, reviewers, and labels, and wait for a yes.
7. **Push and open.** `git push -u origin HEAD`, then `gh pr create --base <base> --title ... --body ...`. Let CODEOWNERS pick reviewers unless the repo says otherwise. For an existing PR, `gh pr edit` instead.

## Done when

The PR exists with a ticket key in the title and a body. Print its URL, then `~/dotfiles/bin/pr-next`. Suggest `/pr-steward <n>` to have CI and review handled while you wait.
