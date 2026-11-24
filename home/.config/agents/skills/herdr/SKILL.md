---
name: herdr
description: "Control Herdr (the Herdr app) through its `hc` CLI: start coding agents such as Claude Code in new terminals, send them prompts, wait for them, and read their output. Use when the user mentions Herdr or hc, or asks to fork, spawn or hand work to a separate interactive agent session. Requires HC_TERMINAL_ID to be set."
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

The installed binary is the authority for syntax. Read `hc --help`, then `hc <command> --help` for the command you
need. Do not run bare `hc`: it opens a picker and attaches. Output is JSON when piped; pass `--json` when you parse it.

## Find terminals

```bash
hc ls          # live terminals: address (t7), agent, cwd, status, where (space / tab)
hc get <t>     # one terminal
```

`<t>` is an address such as `t4f` or a name. This agent's own address is `$HC_TERMINAL_ID`. Read addresses from `hc ls`
or from the result of `hc run`; never guess them.

## Start an agent

Start Claude Code in a new terminal, in the right directory, with its first prompt:

```bash
hc run --bg --name <name> --cwd <dir> --outlive-parent claude "<prompt>"
```

- `--name`: unique among live terminals, 1 to 32 of `a-z 0-9 - _`. Use it as `<t>` afterwards.
- `--cwd`: defaults to where `hc` runs. Pass the worktree the agent should work in.
- `--outlive-parent`: without it the new terminal ends when this agent's program ends. Pass it for any session the
  user should keep, such as a Factory run.
- The new terminal's parent is this one. Herdr types notes about the child (turn ended, blocked, error, exit) into
  the parent; `--no-notify` turns that off.

A slash command works as the first prompt, for example `claude "/pe:factory FOC-712"`.

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
