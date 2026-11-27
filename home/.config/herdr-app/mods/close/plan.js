// What cmd-w does in a space, kept apart from main.js so `node --test` can run it
// (main.js imports Herdr's modules, which only exist inside the app).

// What a tab runs besides idle shells: its agents (sub-agents too, which have no
// pane) and any program in front of a shell (a dev server, an editor).
export function work(tab, panes, agents) {
  const out = agents.filter((a) => a.tab === tab.id).map((a) => a.program?.name || a.app || "an agent");
  for (const p of panes) {
    if (p.tab !== tab.id || !p.terminal || p.program?.agent || p.status) continue;
    if (!p.program?.shell) out.push(p.program?.name || "a program");
  }
  return out;
}

// Idle shells in these tabs.
function shells(tabs, panes) {
  const ids = new Set(tabs.map((t) => t.id));
  return panes.filter((p) => ids.has(p.tab) && p.terminal && p.program?.shell && !p.program?.agent && !p.status).length;
}

// "Claude Code, pnpm and 2 shells".
export function list(names, shellCount = 0) {
  const counts = new Map();
  for (const n of names) counts.set(n, (counts.get(n) ?? 0) + 1);
  const parts = [...counts].map(([n, c]) => (c > 1 ? `${c} × ${n}` : n));
  if (shellCount) parts.push(shellCount === 1 ? "a shell" : `${shellCount} shells`);
  if (!parts.length) return "nothing";
  return parts.length > 1 ? `${parts.slice(0, -1).join(", ")} and ${parts.at(-1)}` : parts[0];
}

// One cmd-w in `space` showing `tab`: { command, args, ask } where ask is
// { title, detail } for the confirm dialog, or null to close at once. Null: nothing to close.
// - Every other tab only idle shells (the "setup" tab once install is done):
//   the whole space, always asked.
// - Otherwise the tab, asked when it runs an agent or a program.
export function plan(space, tab, panes, agents) {
  if (!space || !tab) return null;
  const others = space.tabs.filter((t) => t.id !== tab.id);
  const busy = others.filter((t) => work(t, panes, agents).length);
  if (!busy.length) {
    const names = space.tabs.flatMap((t) => work(t, panes, agents));
    return {
      command: "space.close",
      args: { id: space.id, confirmed: true },
      ask: { title: `Close ${space.name}?`, detail: `Ends ${list(names, shells(space.tabs, panes))}. Its folder stays on disk.` },
    };
  }
  const mine = work(tab, panes, agents);
  const keep = `${busy.map((t) => t.name).join(", ")} keep${busy.length === 1 ? "s" : ""} running.`;
  return {
    command: "tab.close",
    args: { id: tab.id, confirmed: true },
    ask: mine.length ? { title: `Close tab ${tab.name}?`, detail: `Ends ${list(mine)}. ${keep}` } : null,
  };
}
