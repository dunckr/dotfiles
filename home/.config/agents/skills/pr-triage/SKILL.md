---
name: pr-triage
description: Handle every open review thread on a PR (Copilot, Claude and humans) - fix real issues in one commit, reply to and resolve the rest with a reason, and list human design questions for the user. USE WHEN the user says pr-triage, asks to address or answer PR review comments, or pr-next reports unresolved threads.
argument-hint: "<pr number> (defaults to the current branch's PR)"
---

# PR triage

Read the shared rules in `~/.claude/skills/pr-flow/SKILL.md` first.

## Steps

1. **Collect.** Get every unresolved review thread with its comments, path, line, and author:
   ```bash
   gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100){nodes{id isResolved isOutdated path line comments(first:20){nodes{id databaseId author{login} body}}}}}}}' -F o=OWNER -F r=REPO -F n=NUMBER
   ```
   Also read top-level reviews with `gh pr view <n> --json reviews` for change requests.
2. **Classify each thread** by tracing a real caller or input to the claimed failure in the code, not by reading the comment alone:
   - **real**: it fails for a real input. Fix it.
   - **already fixed**: a later commit fixed it. Name the commit.
   - **not worth it**: correct in theory but no real caller reaches it, or the fix costs more than the risk. Give the reason in one sentence.
   - **design question** (usually from a human): a decision about scope or approach. Do not decide it. Leave it open and list it for the user.
3. **Show the table** (thread, author, class, planned action or reply) before changing or posting anything. Wait for a yes, unless running under `/pr-steward`.
4. **Fix** all real ones in one commit (`fix(TICKET): address review comments` or the repo's form), then ask the user to run `preflight` before you push.
5. **Reply and resolve.** For each non-design thread, reply in one or two plain sentences (what changed and the commit, or why not) and resolve it:
   ```bash
   gh api graphql -f query='mutation($t:ID!,$b:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$t,body:$b}){comment{id}}}' -F t=THREAD_ID -F b='...'
   gh api graphql -f query='mutation($t:ID!){resolveReviewThread(input:{threadId:$t}){thread{isResolved}}}' -F t=THREAD_ID
   ```
   Reply to human threads but leave them for the reviewer to resolve unless they asked you to.

## Done when

No thread is without a reply. Print a table of fixed, declined, already fixed, and left open for the user, then `~/dotfiles/bin/pr-next`. If a design question is open, the next step is the user's answer, so say that.
