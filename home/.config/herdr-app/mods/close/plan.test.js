// node --test home/.config/herdr-app/mods/close/plan.test.js
import { test } from "node:test";
import assert from "node:assert/strict";
import { list, plan } from "./plan.js";

const claude = { name: "Claude Code", shell: false, agent: true };
const zsh = { name: "zsh", shell: true, agent: false };
const pnpm = { name: "pnpm", shell: false, agent: false };

const tab = (id, name) => ({ id, name });
const pane = (id, tabId, program, status = null) => ({ pane: id, tab: tabId, terminal: `t-${id}`, program, status });
const agent = (paneId, tabId) => ({ pane: paneId, tab: tabId, program: claude, app: "claude-code" });

// A space as cmd-n makes it: claude in tab 1, the finished setup tab as a shell.
const space = { id: "s1", name: "hs-gateway", tabs: [tab("a", "1"), tab("b", "setup")] };
const panes = [pane("p1", "a", claude, "idle"), pane("p2", "b", zsh)];
const agents = [agent("p1", "a")];

test("closes the whole space when the rest is idle shells, asking once", () => {
  const p = plan(space, space.tabs[0], panes, agents);
  assert.equal(p.command, "space.close");
  assert.deepEqual(p.args, { id: "s1", confirmed: true });
  assert.equal(p.ask.title, "Close hs-gateway?");
  assert.equal(p.ask.detail, "Ends Claude Code and a shell. Its folder stays on disk.");
});

test("a one-tab space closes as a space, asked", () => {
  const one = { ...space, tabs: [tab("a", "1")] };
  const p = plan(one, one.tabs[0], [panes[0]], agents);
  assert.equal(p.command, "space.close");
  assert.ok(p.ask);
});

test("closes only the tab while another tab runs a program, asking for an agent", () => {
  const busy = [panes[0], pane("p2", "b", pnpm)];
  const p = plan(space, space.tabs[0], busy, agents);
  assert.equal(p.command, "tab.close");
  assert.deepEqual(p.args, { id: "a", confirmed: true });
  assert.equal(p.ask.detail, "Ends Claude Code. setup keeps running.");
});

test("closes an idle shell tab at once while another tab has an agent", () => {
  const p = plan(space, space.tabs[1], panes, agents);
  // From setup, tab 1 holds an agent: close setup only, without asking.
  assert.equal(p.command, "tab.close");
  assert.equal(p.ask, null);
});

test("a sub-agent without a pane counts as work", () => {
  const sub = [...agents, { pane: "", tab: "b", program: claude }];
  const p = plan(space, space.tabs[0], panes, sub);
  assert.equal(p.command, "tab.close");
});

test("nothing focused: nothing to close", () => {
  assert.equal(plan(null, null, [], []), null);
});

test("list reads naturally", () => {
  assert.equal(list([], 0), "nothing");
  assert.equal(list(["Claude Code"], 2), "Claude Code and 2 shells");
  assert.equal(list(["Claude Code", "Claude Code", "pnpm"], 1), "2 × Claude Code, pnpm and a shell");
});
