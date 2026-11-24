---
name: herdr
description: "Control the Herdr app from an agent: open a new space (a fresh worktree with its own Claude, like cmd-n), or start a separate interactive agent session in a new terminal, then send it prompts, wait for it and read its output. Use when the user says new space, new workspace, fork, new session, or asks for an agent or subagent in Herdr. A plain \"subagent\" request without Herdr means the built-in Agent tool, not this skill. Requires HC_TERMINAL_ID to be set."
---

# Herdr

The Herdr app runs every terminal through a core server. `hc` (in `PATH`) is its CLI: it starts programs and coding
agents in terminals that stay alive, types into them, waits on them, and reads their screens.

Before issuing any command, check that this agent runs inside a Herdr terminal:

```bash
test -n "${HC_TERMINAL_ID:-}"
```

If the check fails, say that you are not running inside Herdr and stop.

## Learn the CLI

Two CLIs, each with its own guide: `hc` runs and talks to terminals, and `herdr-app` changes what the window shows
(spaces, tabs, panes). `hc --skill` and `herdr-app --skill` print those guides; read the one you need before an
unfamiliar command.

The installed binaries are the authority for syntax. Read `hc --help`, then `hc <command> --help` for the command you
need. Do not run bare `hc`: it opens a picker and attaches. Output is JSON when piped; pass `--json` when you parse it.

## Name every session

Give every session you start a short title that says what it is doing, such as `FOC-712 factory` or
`review: login fix`. Without one, the session is named after its git branch (`claude-session-title`), which says
nothing about the work. The title comes from `CLAUDE_SESSION_NAME`: `space-new --title` sets it for you, and with
`hc run` you put `env CLAUDE_SESSION_NAME="<title>"` before `claude`. It shows as the terminal title in Herdr's
sidebar and in the session picker. Do not use `claude -n`: the SessionStart hook overwrites it.

## Open a new space

When the user asks for a new space or workspace, use `space-new`. It does what cmd-n does: a fresh worktree of the
repo off the latest default branch, a space named after the repo, and install and build in a background "setup" tab.

```bash
~/dotfiles/bin/space-new <repo-folder> --title "<title>" --task "<first message>"
```

- `--task` starts Claude in the space's first tab with that first message, such as `/pe:factory FOC-712`. Leave it
  off for a space with only a shell.
- `--title` names the Claude session and the space's first tab.
- `--argv '["codex"]'` picks another agent.
- The user stays on the space they are looking at; pass `--focus` only when they ask to go there.
- It prints `{"space","folder","main"}`. Find the agent's terminal with `hc ls` (match `cwd` to `folder`) and use the
  steps below to read or wait on it.
- Outside a git repo it opens a plain space in that folder.

## Find terminals

```bash
hc ls          # live terminals: address (t7), agent, cwd, status, where (space / tab)
hc get <t>     # one terminal
```

`<t>` is an address such as `t4f` or a name. This agent's own address is `$HC_TERMINAL_ID`. Read addresses from `hc ls`
or from the result of `hc run`; never guess them.

## Start an agent in a new terminal

For a separate session without a new space or worktree, start Claude Code in a new terminal, in the right directory, with its first prompt:

```bash
hc run --bg --name <name> --cwd <dir> --outlive-parent env CLAUDE_SESSION_NAME="<title>" claude "<prompt>"
```

- `--name`: unique among live terminals, 1 to 32 of `a-z 0-9 - _`. Use it as `<t>` afterwards.
- `--cwd`: defaults to where `hc` runs. Pass the worktree the agent should work in.
- `--outlive-parent`: without it the new terminal ends when this agent's program ends. Pass it for any session the
  user should keep, such as a Factory run.
- The new terminal's parent is this one. Herdr types notes about the child (turn ended, blocked, error, exit) into
  the parent; `--no-notify` turns that off.

A slash command works as the first prompt, for example `claude "/pe:factory FOC-712"`.

In a folder Claude Code has not seen before (a new worktree, a temp dir), it first asks whether to trust the folder and
holds the prompt until that is answered. Herdr does not report this as blocked: `status` stays null and `hc wait` runs
until its timeout. After starting, run `hc read <t>`; if it shows the trust question, ask the user before answering it.

## Talk to it and wait

```bash
hc send <t> "<text>"           # paste and press Enter; --wait waits for the turn it started
hc wait <t>                    # until it stops working; use this, never sleep
hc wait --children any         # the next news from any child of this terminal
hc wait --children all         # until no child is working
hc read <t> --lines 200        # screen plus history
hc keys <t> esc                # keys: enter, esc, up, ctrl+c
hc interrupt <t>               # press the stop key and report what happened
```

`hc send` refuses a terminal that is blocked on a dialog unless `--force` is passed. If a child is blocked, read it
and ask the user before answering the dialog.

## Ordinary commands

`hc run <cmd>` runs a command in a new terminal and waits like a shell; `--bg` returns at once. `hc exec <cmd>` runs
without a terminal and prints its output.

## Safety

- Only `kill` or `rm` terminals you started, unless the user asks.
- Never run `hc server stop` or `hc server restart` unless the user asks: it affects every terminal.
- Never run `hc attach` from an agent: it takes over this terminal.
