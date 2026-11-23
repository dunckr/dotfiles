no emdashes (—) ever
branch names: ticket number (`ABC-123`) or a `feat|fix|chore|refactor|docs|test` prefix, lowercase and hyphenated, never containing "claude" or any agent name
commit messages: plain English per the claudish skill (no metaphor, abstraction, or filler); one line, lowercase, imperative, under ~50 chars, no body, no prefix, no trailing period; join separate changes with `; ` (e.g. `fix tab bar`, `use sf mono; add nerd font symbols`); if the branch name starts with a ticket number, prefix the message with it in uppercase (e.g. branch `abc-123-tab-bar` gives `ABC-123 fix tab bar`)
pull requests: title follows the commit message rules, including the ticket prefix, so the squash merge commit carries it; body is empty (`gh pr create --title "..." --body ""`), no summary, test plan, or checklist
text edits: when changing markdown or other prose files, run the changed text through the claudish skill; apply it only to the lines you changed or added, never rewrite untouched text
web: use the `puppeteer` MCP (chrome-devtools-mcp) by default, playwright only as a fallback; the browser is visible but must never take focus, so open pages with `background: true`, never pass `bringToFront`, never launch a browser yourself or `open` a URL, and never drive a visible app via AppleScript or computer use

@RTK.md
