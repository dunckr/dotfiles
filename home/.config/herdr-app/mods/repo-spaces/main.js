// Cloned from Herdr's spaces mod. Workspace spaces: stable colored avatars
// with the space's number (what space.select, cmd-1 to cmd-9, picks),
// under a header per repo, grouped by machine when more than one is known.
// Repos are sorted by folder, with a line between parent folders (all of
// ~/work together, say). After a space's name, the repo
// its first terminal is in now, only where unusual: branch, ahead/behind. Agent state lives in the agents list, not here. Click to
// switch, right-click for its menu, drag to reorder within a repo.
// Under a space's name, when it has them: its GitHub PR (from gh, by a "PR 123"
// in its name, its branch or its commit) and its Jira ticket (from the PR title,
// name or branch; a branch is lowercase, so it goes last: "stack-760" isn't one), on the site its direnv's JIRA_SITE or acli's config gives),
// and while the PR is open, its checks: failed, running or passed.
// Click one to open it.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, ScrollHandle } from "gpui-base";
import { spaces, machines, panes, run, openOverlay, exec, hc, theme, shared, setShared, watchFolder, window, layout, readTextFile, home } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// Where a space is now: its first terminal's live folder, else where it was made.
// `ps`: panes(), read once by the caller (each read copies every pane).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}
const rowHeight = ({ tree }) => (tree ? 28 : 30);
const RAIL_CELL = 32;
// A space's name and its git tail never shrink below this, so a short one ("api")
// stays readable instead of turning into an ellipsis next to a long branch.
const SIDE_MIN = 48;
const railCell = (el) => h_flex().flex_none().justify_center().child(el);
const where = (s, ps) => JSON.stringify([s.machine ?? null, place(s, ps)]);
const base = (path) => path.replace(/\/+$/, "").split("/").pop();
// A repo's name from its git folder: the folder holding .git, a bare repo's own
// name, or the folder holding a hidden bare repo (<project>/.bare).
const repoName = (common) => {
  if (common.endsWith("/.git")) return base(common.slice(0, -5));
  const own = base(common);
  return own === ".bare" ? base(common.slice(0, -own.length - 1)) : own.replace(/\.git$/, "");
};
// A repo's own folder from its git folder, by the same rules as repoName.
const repoRoot = (common) => {
  if (common.endsWith("/.git")) return common.slice(0, -5);
  return base(common) === ".bare" ? common.replace(/\/+$/, "").slice(0, -6) : common.replace(/\.git$/, "");
};
const parentOf = (path) => path.replace(/\/+$/, "").replace(/\/[^/]*$/, "") || "/";
// Changes made outside Herdr (an editor's save, a commit in another app): looked
// for this often, in repos the list shows, while the window is in front.
const FALLBACK = 60000;
// Places looked at together (two git runs each). All at once, a few hundred spaces
// run out of the app's open files (256 when started from the Dock on macOS) or
// past a machine core's 16 running execs, and those spaces wait for FALLBACK.
const AT_ONCE = 6;

// Both runs, finished: a place isn't done while one of its runs still holds a slot.
async function both(a, b) {
  const done = await Promise.allSettled([a, b]);
  const failed = done.find((d) => d.status === "rejected");
  if (failed) throw failed.reason;
  return done.map((d) => d.value);
}

// A space's PR is asked of GitHub at most this often, while the window is in front.
const PR_EVERY = 60000;
// Sooner while its checks run, so the result shows soon after they finish.
const PR_RUNNING_EVERY = 20000;
const PR_FIELDS = "number,url,state,isDraft,title,statusCheckRollup";
// A PR's checks (GitHub Actions runs and commit statuses) in one: how many failed,
// how many still run, of how many, and the failed ones' names. Null when it has none.
function rollup(list) {
  const done = ["SUCCESS", "NEUTRAL", "SKIPPED", "STALE"];
  const runs = (list ?? []).map((c) => ({
    name: c.name || c.context || "check",
    is: c.__typename === "StatusContext"
      ? (c.state === "SUCCESS" ? "pass" : c.state === "PENDING" || c.state === "EXPECTED" ? "run" : "fail")
      : c.status !== "COMPLETED" ? "run" : done.includes(c.conclusion) ? "pass" : "fail",
  }));
  if (!runs.length) return null;
  const failed = runs.filter((r) => r.is === "fail").map((r) => r.name);
  return { fail: failed.length, run: runs.filter((r) => r.is === "run").length, total: runs.length, failed };
}
// What a space's PR is found by: a number in its name or session ("PR 380 FOC-1442"),
// else its branch, else (detached) its commit. The trunk has none.
function prTarget(w, g, session) {
  if (!g) return null;
  const n = `${w.name} ${session ?? ""}`.match(/\bPR\s*#?(\d+)\b/i)?.[1];
  if (n) return { key: `${g.repo}|#${n}`, args: ["pr", "view", n] };
  if (g.branch === "(detached)") return g.sha ? { key: `${g.repo}|@${g.sha}`, args: ["pr", "list", "--state", "all", "--limit", "1", "--search", g.sha], list: true } : null;
  if (g.branch === "main" || g.branch === "master") return null;
  return { key: `${g.repo}|${g.branch}`, args: ["pr", "view", g.branch] };
}
// A Jira key after the start, a slash, a bracket or a space: "abc-123-tab-bar",
// "feature/FOC-1442-file-type", "feat(FOC-1442): ...". Branches may be lowercase;
// in prose only capitals count ("covid-19" isn't one). Not a branch prefix followed
// by a number ("fix-2-crash").
const ticketIn = (s, anyCase) => (s ?? "").match(new RegExp("(?:^|[/(\\[\\s])(?!(?:feat|fix|chore|refactor|docs|test|v)-)([A-Z][A-Z0-9]+-\\d+)(?![A-Za-z0-9])", anyCase ? "i" : ""))?.[1]?.toUpperCase() ?? null;
const siteUrl = (s) => (s ? (/^https?:\/\//.test(s) ? s : `https://${s}`).replace(/\/+$/, "") : null);
const openUrl = (url) => exec(window()?.platform === "windows" ? "explorer" : window()?.platform === "linux" ? "xdg-open" : "open", [url]).catch(() => {});

// What a stored color name looks like on an avatar (the same in every mod
// that draws space avatars): one strong color per hue, light and dark alike.
const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };

// A space's session name, as the agents list reads it: its agent tab's name
// when someone named it, else the agent's own title (a Claude session's name).
// clean, leadPanes and title are copied from Herdr's agents mod.
const clean = (s) => (s ?? "").replace(/^(?:\[ [!.] \] |[✋⏳]\uFE0F?(?=\s)|(?!(?:\p{Emoji}\uFE0F|[#*]\u20E3))[^\p{L}\p{N}\p{Ps}\p{Pi}\p{Emoji_Presentation}])+/u, "").trim();

function leadPanes(all) {
  const leads = new Map();
  for (const p of all) {
    if (!p.terminal) continue;
    const current = leads.get(p.tab);
    if (!current || (!current.program?.agent && (p.program?.agent || (!current.focused && p.focused)))) leads.set(p.tab, p);
  }
  return leads;
}

function title(tab, l) {
  const prog = l?.program?.name;
  const live = clean(l?.title);
  const path = /^[~/]|^[A-Za-z]:\\/.test((l?.title ?? "").replace(/^[^\p{L}\p{N}~/]+/u, ""));
  const telling = live && live !== (l?.terminal ?? l?.address) && live !== prog && !path && !live.includes("@") && live.toLowerCase() !== l?.program?.key;
  return (tab.name === prog || !tab.named) && telling ? live : tab.name;
}

function session(w, leads) {
  const tabs = w.tabs ?? [];
  const tab = tabs.find((t) => leads.get(t.id)?.program?.agent);
  if (!tab) return null;
  const s = title(tab, leads.get(tab.id));
  return !s || /^\d+$/.test(s) ? null : s;
}

// A space speaks up only when something in it needs you.
export function glyph(status) {
  return status === "blocked" || status === "done" ? "●" : "·";
}

export function tone(t, status) {
  return t[status] ?? t.unknown;
}

export default class Spaces extends View {
  init(_props, cx) {
    this.git = {}; // where() -> { name, branch, ahead, behind, repo, linked }, null: not a repo
    this.checked = {}; // where() -> when it was last looked at
    this.unsure = new Set(); // where()s git couldn't answer for (a machine away)
    this.pending = new Set(); // where()s to look at next
    this.busy = {}; // pane -> an agent working or a program in front of its shell
    this.ready = {}; // machine -> its layout was readable at the last look
    this.at = {}; // space -> its where() at the last look
    this.watching = new Map(); // local repos' pending folder watches
    // Spaces made while this runs wait (at most a moment) for their git, so a
    // worktree appears under its repo instead of jumping there.
    this.shown = new Set(spaces().map((s) => s.id));
    this.born = {};
    this.pressed = null;
    this.over = null;
    this.scroll = ScrollHandle.new(); // the list's position: the active space is brought into view through it
    this.activeAt = -1; // the active space's place among the list's children (headers and rows), -1 when not drawn
    this.machines = [];
    this.prs = {}; // prTarget().key -> { number, url, state, draft, title }, null: no PR
    this.prChecked = {}; // prTarget().key -> when GitHub was last asked
    this.prPending = new Map(); // prTarget().key -> { cwd, on, args, list } to ask about next
    this.sites = {}; // repo -> its Jira site, from JIRA_SITE in its direnv
    this.jira = null; // the Jira site elsewhere, from acli's config
    cx.spawn(async (cx) => {
      try {
        const yaml = await readTextFile(`${home()}/.config/acli/jira_config.yaml`);
        const site = yaml.match(/site:\s*["']?([\w.-]+)/)?.[1];
        if (site) { this.jira = `https://${site}`; cx.notify(); }
      } catch {}
    });
    try {
      this.reconnecting = JSON.parse(localStorage.getItem("machines.reconnecting") ?? "{}");
      if (!this.reconnecting || typeof this.reconnecting !== "object" || Array.isArray(this.reconnecting)) this.reconnecting = {};
      for (const state of Object.values(this.reconnecting)) state.busy = false;
    } catch { this.reconnecting = {}; }
    try { this.folded = new Set(JSON.parse(localStorage.getItem("machines.folded") ?? "[]")); } catch { this.folded = new Set(); }
    try { this.foldedGroups = new Set(JSON.parse(localStorage.getItem("groups.folded") ?? "[]")); } catch { this.foldedGroups = new Set(); }
    this.refreshMachines(cx);
    cx.timer.every(15000, cx => this.refreshMachines(cx));
    // Refresh only when the refs could have changed (see `due`).
    cx.timer.every(250, (cx) => this.checkNew(cx));
  }

  checkNew(cx) {
    const now = Date.now();
    const sp = spaces();
    for (const s of sp) if (!this.shown.has(s.id)) this.born[s.id] ??= now;
    const due = this.due(now, sp, panes());
    if (due.size) this.refreshGit(due, cx);
    if (now - (this.prScan ?? 0) > 2000) {
      this.prScan = now;
      this.queuePrs(sp, cx);
    }
    if (sp.some((s) => !this.shown.has(s.id)) || this.orderingDue(now)) cx.notify();
  }

  // Places whose git could have changed: new ones (a new space, a cd), where a
  // command or an agent's turn just ended (a checkout, a commit, edits), those on
  // a machine that is back, and repos in view whose fallback is due.
  due(now, sp, ps) {
    // Moved there: what it knew of that place may be old.
    const at = {};
    for (const s of sp) at[s.id] = where(s, ps);
    const keys = new Set(Object.values(at).filter((k) => JSON.parse(k)[1]));
    for (const k of Object.keys(this.git)) if (!keys.has(k)) {
      delete this.git[k];
      delete this.checked[k];
      this.unsure.delete(k);
    }
    const repos = new Set(Object.values(this.git).filter(Boolean).map((g) => g.repo));
    for (const [repo, pending] of this.watching) if (!repos.has(JSON.stringify([null, repo]))) {
      this.watching.delete(repo);
      pending.cancel();
    }
    const due = new Set([...keys].filter((k) => !(k in this.git)));
    for (const [id, k] of Object.entries(at)) if (this.at[id] && this.at[id] !== k && keys.has(k)) due.add(k);
    this.at = at;
    const spaceOf = {};
    for (const s of sp) for (const t of s.tabs ?? []) spaceOf[t.id] = s;
    const busy = {};
    for (const p of ps) {
      if (!p.terminal || !spaceOf[p.tab]) continue;
      busy[p.pane] = p.status === "working" || !(p.program?.shell || p.program?.agent);
      if (this.busy[p.pane] && !busy[p.pane]) this.sameRepo(at[spaceOf[p.tab].id], keys).forEach((k) => due.add(k));
    }
    this.busy = busy;
    for (const m of machines()) {
      const ready = m.layout === "ready";
      if (ready && this.ready[m.name] === false) for (const k of keys) if (JSON.parse(k)[0] === m.name) due.add(k);
      this.ready[m.name] = ready;
    }
    if (window().active) {
      for (const k of keys) {
        const asks = this.git[k] || this.unsure.has(k);
        if (asks && !this.folded.has(JSON.parse(k)[0]) && now - (this.checked[k] ?? 0) > FALLBACK) due.add(k);
      }
    }
    return due;
  }

  // `key` and the other places in its repo (a commit there moves their ahead/behind).
  sameRepo(key, keys) {
    const repo = this.git[key]?.repo;
    return [key, ...(repo ? [...keys].filter((k) => this.git[k]?.repo === repo) : [])];
  }

  refreshMachines(cx) {
    cx.spawn(async cx => {
      try { const r = await hc(["machine", "ls", "--json"]); if (r.code === 0) this.machines = (JSON.parse(r.stdout).machines ?? []).filter((m) => !m.temporary); } catch {}
      cx.notify();
    });
  }

  rebuilt(machine) {
    return machine?.state === "unreachable" && /^a different core answers there \("[^"]+"\)$/.test(machine.why ?? "");
  }

  reconnect(machine, cx) {
    const name = machine.name;
    if (this.reconnecting[name]?.busy) return;
    const state = this.reconnecting[name] ??= { machine, removed: false };
    state.busy = true;
    state.error = null;
    localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
    cx.notify();
    cx.spawn(async cx => {
      try {
        const ask = async args => {
          const r = await hc([...args, "--json"]);
          if (r.code !== 0) {
            let error;
            try { error = JSON.parse(r.stdout || r.stderr).error?.message; } catch {}
            throw new Error(error || r.stderr || r.stdout || "Couldn't connect.");
          }
        };
        if (!state.removed) {
          await ask(["machine", "rm", name]);
          state.removed = true;
          localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
        }
        const args = ["machine", "add"];
        if (machine.via) args.push("--via", machine.target);
        else args.push(machine.target);
        args.push("--name", name);
        if (machine.session) args.push("--session", machine.session);
        if (machine.temporary) args.push("--temp");
        await ask(args);
        this.folded.delete(name);
        localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
        delete this.reconnecting[name];
      } catch (e) {
        state.error = String(e.message ?? e);
        state.busy = false;
      }
      localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
      this.refreshMachines(cx);
      cx.notify();
    });
  }

  // One look at a time, each place once however often it was asked for meanwhile.
  refreshGit(keys, cx) {
    for (const k of keys) this.pending.add(k);
    if (this.refreshing) return;
    this.refreshing = true;
    cx.spawn(async (cx) => {
      while (this.pending.size) {
        const keys = [...this.pending];
        this.pending.clear();
        let next = 0;
        await Promise.all(Array.from({ length: Math.min(AT_ONCE, keys.length) }, async () => {
          while (next < keys.length) await this.check(keys[next++], cx);
        }));
      }
      this.refreshing = false;
      cx.notify();
    });
  }

  // One place's git: branch, ahead/behind, its repo.
  async check(key, cx) {
    const [on, cwd] = JSON.parse(key);
    this.checked[key] = Date.now();
    this.unsure.delete(key);
    try {
      // Ref-only reads avoid scanning the worktree or waking its index watch.
      // Two reads: a folder name may itself contain a newline.
      const [r, common] = await both(
        exec("git", ["rev-parse", "--path-format=absolute", "--show-toplevel"], { cwd, on }),
        exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd, on }),
      );
      if (r.code !== 0 || common.code !== 0) {
        // Only git's own "no" is remembered as no repo; anything else is asked again.
        if (!/not a git repository/i.test(r.code !== 0 ? r.stderr : common.stderr)) {
          this.unsure.add(key);
          this.git[key] ??= null;
        } else this.git[key] = null;
        return;
      }
      // The repo's own .git folder names it; a worktree's top differs from it.
      const top = r.stdout.replace(/\n$/, ""), repo = common.stdout.replace(/\n$/, "");
      const [branch, counts] = await both(
        exec("git", ["symbolic-ref", "-q", "HEAD"], { cwd, on }),
        exec("git", ["rev-list", "--left-right", "--count", "HEAD...@{upstream}"], { cwd, on }),
      );
      const name = repoName(repo);
      // A detached HEAD's PR is found by its commit.
      const sha = branch.code !== 0 ? (await exec("git", ["rev-parse", "HEAD"], { cwd, on })).stdout.trim() || null : null;
      const [ahead, behind] = counts.code === 0 ? counts.stdout.trim().split(/\s+/).map(Number) : [0, 0];
      const info = { name, branch: branch.code === 0 ? branch.stdout.trim().replace(/^refs\/heads\//, "") : "(detached)", ahead, behind, repo: JSON.stringify([on, repo]), root: repoRoot(repo), linked: repo !== `${top}/.git`, sha };
      this.git[key] = info;
      if (!on) this.watch(repo, cx);
    } catch {
      // Couldn't ask (the machine is away): keep what it showed, look again later.
      this.git[key] ??= null;
      this.unsure.add(key);
    }
  }

  // Each space's PR, from gh in its folder: new ones at once, the rest once per
  // PR_EVERY while the window is in front. Asked two at a time in the background.
  queuePrs(sp, cx) {
    const ps = panes(), leads = leadPanes(ps), now = Date.now();
    for (const s of sp) {
      const g = this.git[where(s, ps)];
      const target = prTarget(s, g, session(s, leads));
      if (!target) continue;
      const at = this.prChecked[target.key];
      const every = this.prs[target.key]?.checks?.run ? PR_RUNNING_EVERY : PR_EVERY;
      if (at && (!window().active || now - at < every)) continue;
      this.prChecked[target.key] = now;
      this.prPending.set(target.key, { ...target, cwd: place(s, ps), on: s.machine ?? null, repo: g.repo });
    }
    if (this.prAsking || !this.prPending.size) return;
    this.prAsking = true;
    cx.spawn(async (cx) => {
      const one = async () => {
        for (let next; (next = this.prPending.entries().next().value);) {
          const [k, ask] = next;
          this.prPending.delete(k);
          await this.askPr(k, ask);
          cx.notify();
        }
      };
      await Promise.all([one(), one()]);
      this.prAsking = false;
    });
  }

  // One PR. gh runs under the folder's direnv when there is one (a repo can set its
  // own GH_CONFIG_DIR, a work account), which also says its JIRA_SITE.
  async askPr(k, { cwd, on, args, list, repo }) {
    const gh = [...args, "--json", PR_FIELDS];
    let r, site = null;
    try {
      r = await exec("direnv", ["exec", cwd, "sh", "-c", 'printf "%s\\n" "$JIRA_SITE"; exec gh "$@"', "sh", ...gh], { cwd, on, timeout: 20000 });
      const nl = r.stdout.indexOf("\n");
      site = r.stdout.slice(0, nl).trim();
      r = { ...r, stdout: r.stdout.slice(nl + 1) };
    } catch {
      // No direnv there.
      try { r = await exec("gh", gh, { cwd, on, timeout: 20000 }); } catch { return; }
    }
    if (site) this.sites[repo] = siteUrl(site);
    try {
      if (r.code === 0) {
        const found = JSON.parse(r.stdout);
        const pr = list ? found[0] : found;
        this.prs[k] = pr ? { number: pr.number, url: pr.url, state: pr.state, draft: pr.isDraft, title: pr.title, checks: rollup(pr.statusCheckRollup) } : null;
      } else if (/no pull requests found/i.test(r.stderr)) this.prs[k] = null;
      // Anything else (offline, no gh there, not GitHub): keep what it showed.
    } catch {}
  }

  watch(repo, cx) {
    if (this.watching.has(repo)) return;
    const pending = watchFolder(repo);
    this.watching.set(repo, pending);
    cx.spawn(async (cx) => {
      let current = pending;
      try {
        for (;;) {
          await current;
          if (this.watching.get(repo) !== current) return;
          const mine = JSON.stringify([null, repo]);
          const keys = Object.keys(this.git).filter((k) => this.git[k]?.repo === mine);
          if (!keys.length) break;
          this.refreshGit(keys, cx);
          current = watchFolder(repo);
          this.watching.set(repo, current);
        }
      } catch {}
      if (this.watching.get(repo) === current) this.watching.delete(repo);
    });
  }

  menu(w) {
    // A popup is as tall as its items; height is only the most.
    openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: w.id } } });
  }

  orderingDue(now) {
    return this.ordering && now - this.ordering.at >= 1000
      && this.ordering.machines.every(name => machines().some(m => m.name === name && m.layout === "ready"));
  }

  // Spaces in order, grouped by repo within each machine: groups sorted by the
  // repo's folder, each repo's main checkout first, spaces outside a repo last
  // under Other. Until git answers, a space groups by its name and sorts by
  // where it is.
  ordered() {
    const sp = spaces(), ps = panes();
    const ready = (w) => this.shown.has(w.id) || where(w, ps) in this.git || Date.now() - (this.born[w.id] ??= Date.now()) > 1500;
    for (const w of sp) if (!this.shown.has(w.id) && ready(w)) this.shown.add(w.id);
    const leads = leadPanes(ps);
    const list = sp.map((w, i) => {
      const k = where(w, ps);
      return { w, i, g: this.git[k] ?? null, known: k in this.git, session: session(w, leads), at: place(w, ps) ?? "" };
    });
    const groups = new Map();
    for (const r of list) {
      const m = JSON.stringify(r.w.machine ?? null);
      const other = !r.g && r.known;
      const key = `${m}|${r.g ? r.g.repo : other ? "other" : `name:${r.w.name.toLowerCase()}`}`;
      const root = r.g?.root ?? r.at;
      if (!groups.has(key)) groups.set(key, { m, other, root, parent: other ? null : parentOf(root), label: r.g?.name ?? (other ? "Other" : r.w.name), rows: [] });
      groups.get(key).rows.push(r);
    }
    const out = [];
    for (const m of new Set([...groups.values()].map((g) => g.m))) {
      const mine = [...groups.entries()].filter(([, g]) => g.m === m);
      const byFolder = ([, a], [, b]) => a.parent.localeCompare(b.parent) || a.root.localeCompare(b.root);
      for (const [key, g] of [...mine.filter(([, g]) => !g.other).sort(byFolder), ...mine.filter(([, g]) => g.other)]) {
        const rows = [...g.rows.filter((r) => !r.g?.linked), ...g.rows.filter((r) => r.g?.linked)];
        for (const r of rows) out.push({ ...r, tree: null, group: key, label: g.label, other: g.other, parent: g.parent });
      }
    }
    // Simulate the batch so later indexes include earlier moves. An attempted
    // write can lose a sync conflict: allow the echo to settle before retrying.
    // Not while some git is unknown: its space could still change group.
    const order = sp.map(w => w.id);
    const target = out.map(r => r.w.id);
    const key = JSON.stringify([order, target, machines()]);
    if (!list.every((r) => r.known)) {
      // wait for git
    } else if (order.every((id, i) => id === target[i])) {
      this.ordering = null;
    } else if (this.ordering?.key !== key || this.orderingDue(Date.now())) {
      const moved = new Set();
      this.ordering = { key, at: Date.now(), machines: [] };
      for (let i = 0; i < out.length; i++) {
        const from = order.indexOf(out[i].w.id);
        if (from === i) continue;
        run("space.move", { id: out[i].w.id, index: i + 1 });
        moved.add(out[i].w.machine ?? null);
        order.splice(i, 0, order.splice(from, 1)[0]);
      }
      this.ordering.machines = [...moved];
    }
    return out.filter(r => this.shown.has(r.w.id));
  }

  // Rows with a header above each group (in the rail, a gap), and where the
  // active space's row lands among them. A click on a header folds its group;
  // folded, it says how many spaces it holds.
  withHeaders(rows, draw, t, collapsed) {
    const items = [];
    let activeAt = -1;
    rows.forEach((r, n) => {
      const first = n === 0;
      const folded = !collapsed && this.foldedGroups.has(r.group);
      if (first || rows[n - 1].group !== r.group) {
        const count = rows.filter((k) => k.group === r.group).length;
        // A line where the parent folder changes: one folder's repos apart from the rest.
        if (!collapsed && !first && rows[n - 1].parent !== r.parent) items.push(div().id(`divider-${r.group}`).h(1).flex_none().mx(8).mt(8).bg(t.border));
        if (!collapsed) items.push(h_flex().id(`group-${r.group}`).h(24).flex_none().px(8).gap(6).when(!first, (el) => el.mt(8))
          .items_center().text_size(11).text_color(t.dim).cursor_pointer().hover((s) => s.text_color(t.foreground))
          .on_click((_e, cx) => {
            folded ? this.foldedGroups.delete(r.group) : this.foldedGroups.add(r.group);
            localStorage.setItem("groups.folded", JSON.stringify([...this.foldedGroups]));
            cx.notify();
          })
          .child(div().truncate().child(r.label))
          .when(folded, (el) => el.child(div().flex_none().child(String(count))))
          .child(div().flex_1())
          .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none()));
        else if (!first) items.push(div().id(`group-${r.group}`).h(8).flex_none());
      }
      if (folded) return;
      if (r.w.active) activeAt = items.length;
      items.push(draw(r));
    });
    return { items, activeAt };
  }

  // The rows, under a header per machine once one isn't this computer.
  grouped(t, collapsed) {
    const rows = this.ordered();
    const draw = (r) => (collapsed ? this.compact(r, t) : this.row(r, t));
    // Where the active space's row lands among the children this returns: the list scrolls by its direct
    // children, and machine headers, login notes and loading rows count too.
    this.activeAt = -1;
    let before = 0;
    const remote = [...new Set([...rows.map(r => r.w.machine).filter(Boolean), ...this.machines.map(m => m.name), ...Object.keys(this.reconnecting)])].sort();
    const loading = m => {
      const layout = machines().find(k => k.name === m)?.layout;
      return layout === "loading" || (!layout && this.machines.some(k => k.name === m && k.state === "connected"))
        || spaces().some(s => (s.machine ?? null) === m && !this.shown.has(s.id));
    };
    const loadingRow = m => h_flex().id(`machine-loading-${m ?? "local"}`).h(28).flex_none().px(collapsed ? 0 : 8).items_center().when(collapsed, el => el.justify_center()).text_size(12).text_color(t.dim).child(collapsed ? "…" : "Loading…");
    if (!remote.length) {
      if (loading(null) && !rows.length) return [loadingRow(null)];
      const { items, activeAt } = this.withHeaders(rows, draw, t, collapsed);
      this.activeAt = activeAt;
      return items;
    }
    const machineNames = [null, ...remote];
    return machineNames.flatMap((m) => {
      const mine = rows.filter((r) => (r.w.machine ?? null) === m);
      const repair = this.reconnecting[m];
      const machine = this.machines.find(k => k.name === m) ?? repair?.machine;
      const connected = !m || machine?.state === "connected";
      const rebuilt = this.rebuilt(machine) || !!repair;
      const login = machine?.state === "needs_login" ? `hc machine login ${m}` : null;
      const folded = this.folded.has(m);
      const icon = svg(`mods/workspace-chrome/${m ? "server" : "monitor"}.svg`).size(13).flex_none();
      const badge = div().absolute().right(-3).bottom(-2).size(6).rounded(3).border_1().border_color(t.chrome).bg(connected ? t.ansi2 : t.dim);
      const head = h_flex().id(`machine-${m ?? "local"}`).h(26).flex_none().px(collapsed ? 0 : 8).gap(7).items_center().text_size(11).text_color(t.dim)
        .when(collapsed, el => el.mt(4).w(RAIL_CELL).justify_center().rounded(6).tooltip(login ? `${m} needs a login: run ${login}. Click for Copy.` : m ? `${m} · ${connected ? "connected" : (machine?.state ?? "asleep").replace(/_/g, " ")}` : "This computer"))
        .cursor_pointer().hover(s => s.bg(t.hover))
        .on_click((_e, cx) => {
          if (collapsed && login) { run("app.settings", { section: "machines" }); return; }
          folded ? this.folded.delete(m) : this.folded.add(m);
          localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
          cx.notify();
        })
        .when(machine?.keeps_running_after_logout === false, el => el.child(div().id(`machine-logout-${m}`)
          .flex_none().text_color(t.blocked).tooltip("Agents stop when you disconnect. Click for the fix.")
          .on_click((_e, cx) => { cx.stop_propagation(); openOverlay({ mod: "machine-add", kind: "dialog", width: 560 }); }).child("⚠")))
        .when(!collapsed, el => el.child(icon))
        .when(collapsed, el => el.child(div().relative().flex_none().child(icon).when(Boolean(m), el => el.child(badge))))
        .when(!collapsed, el => el.child(div().flex_1().truncate().child(m ?? "This computer"))
          .when(!connected && !rebuilt && !login, el => el.child(div().flex_none().child((machine?.state ?? "asleep").replace(/_/g, " "))))
          .when(rebuilt, el => el.child(h_flex().flex_none().gap(3).items_center()
            .child(div().max_w(140).truncate().child(repair?.error || "rebuilt ·"))
            .child(div().id(`machine-connect-${m}`).text_color(repair?.error ? t.blocked : t.muted)
              .hover(s => s.text_color(t.foreground))
              .tooltip(repair?.error || "This machine was rebuilt or replaced. Click to connect to the new one.")
              .on_click((_e, cx) => { cx.stop_propagation(); this.reconnect(machine, cx); })
              .child(repair?.busy ? "Connecting…" : "Connect"))))
          .when(connected, el => el.child(div().id(`machine-add-${m ?? "local"}`).flex_none().px(4).rounded(4).hover(s => s.bg(t.hover).text_color(t.foreground))
            .on_click((_e, cx) => { cx.stop_propagation(); run("space.new", { machine: m ?? "" }); }).child("+")))
          .child(div().size(6).rounded(3).flex_none().bg(connected ? t.ansi2 : t.dim))
          .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none()));
      const empty = h_flex().id(`machine-new-${m ?? "local"}`).h(28).flex_none().px(collapsed ? 0 : 8).gap(7).items_center().rounded(7)
        .text_size(12).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
        .on_click(() => run("space.new", { machine: m ?? "" }))
        .when(collapsed, el => el.w(RAIL_CELL).rounded(6).justify_center().tooltip(`New space on ${m ?? "this computer"}`)
          .child(h_flex().size(18).rounded(5).border_1().border_color(t.dim).items_center().justify_center()
            .child(svg("mods/workspace-chrome/plus.svg").size(10))))
        .when(!collapsed, el => el.child(svg("mods/workspace-chrome/plus.svg").size(12)).child("New space there"));
      if (!collapsed && rebuilt) { before += 1; return [head]; }
      const cell = collapsed ? railCell : (el) => el;
      const guidance = !collapsed && login ? [v_flex().px(8).pb(6).gap(3).flex_none()
        .child(div().text_size(11).text_color(t.blocked).child("needs a login: run"))
        .child(h_flex().gap(5).items_center()
          .child(div().flex_1().min_w(0).truncate().tooltip(login).text_size(11).text_color(t.muted).child(login))
          .child(div().id(`machine-login-copy-${m}`).flex_none().px(5).py(2).rounded(4)
            .text_size(11).text_color(t.foreground).bg(t.raised).cursor_pointer().hover(s => s.bg(t.hover))
            .on_click((_e, cx) => { cx.stop_propagation(); cx.write_to_clipboard(login); this.copiedLogin = login; cx.notify(); })
            .child(this.copiedLogin === login ? "Copied" : "Copy")))] : [];
      const body = this.withHeaders(mine, draw, t, collapsed);
      const items = [cell(head), ...guidance, ...(folded ? [] : mine.length ? body.items : [loading(m) ? loadingRow(m) : cell(empty)])];
      const first = folded ? -1 : body.activeAt;
      if (first >= 0) this.activeAt = before + 1 + guidance.length + first;
      before += items.length;
      return items;
    });
  }

  // Only what's unusual, after the name: "herdr \u00b7 spike \u21912 \u21931". The repo or
  // branch goes when the name already says it (a worktree is named after its branch),
  // and master/main go: nearly every space is on one. When the row is full, it
  // and the name both start from their text's width and give way in proportion.
  gitTail(g, tree, name, t) {
    const raw = g.branch ?? "detached";
    const same = (a) => a.toLowerCase() === name.toLowerCase();
    const branch = same(raw) || raw === "master" || raw === "main" ? "" : raw;
    const repo = tree || same(g.name) ? "" : g.name;
    const where = [repo, branch].filter(Boolean).join(" \u00b7 ");
    return h_flex()
      .flex_auto()
      .min_w(where ? SIDE_MIN : 0)
      .gap(5)
      .justify_end()
      .items_center()
      .text_size(11.5)
      .text_color(t.dim)
      .when(Boolean(where), (el) => el.child(div().min_w(0).truncate().child(where)))
      .when(g.ahead > 0, (el) => el.child(div().flex_none().text_color(t.ansi2).child(`\u2191${g.ahead}`)))
      .when(g.behind > 0, (el) => el.child(div().flex_none().text_color(t.ansi1).child(`\u2193${g.behind}`)));
  }

  // The line under a space's name: its PR and Jira ticket, each opened by a click.
  // Null when its branch has neither.
  links(w, g, session, t) {
    if (!g) return null;
    const target = prTarget(w, g, session);
    const pr = target ? this.prs[target.key] ?? null : null;
    const jira = this.sites[g.repo] ?? this.jira;
    const ticket = jira ? ticketIn(pr?.title) ?? ticketIn(w.name) ?? ticketIn(session) ?? ticketIn(g.branch, true) : null;
    if (!pr && !ticket) return null;
    const tint = !pr ? t.dim : pr.state === "MERGED" ? t.ansi5 : pr.state === "CLOSED" || pr.draft ? t.dim : t.ansi2;
    const chip = (id, icon, color, text, tip, url, spin) => h_flex().id(`${id}-${w.id}`).h(16).px(4).gap(4).flex_none().items_center().rounded(4)
      .text_size(11).text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground)).cursor_pointer().tooltip(tip)
      // Not a press on the row: no select, no drag.
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); openUrl(url); })
      .child(svg(icon.includes("/") ? icon : `mods/repo-spaces/${icon}.svg`).size(11).flex_none().text_color(color).when(Boolean(spin), (el) => el.spin(900)))
      .when(Boolean(text), (el) => el.child(text));
    // Checks only matter while the PR is open.
    const c = pr?.state === "OPEN" ? pr.checks : null;
    const checks = !c ? null
      : c.fail ? chip("checks", "mods/workspace-chrome/x.svg", t.blocked, String(c.fail), `Failed: ${c.failed.join(", ")}`, `${pr.url}/checks`)
      : c.run ? chip("checks", "mods/workspace-chrome/spinner.svg", t.working, `${c.total - c.run}/${c.total}`, `${c.run} of ${c.total} checks running`, `${pr.url}/checks`, true)
      : chip("checks", "mods/workspace-chrome/check.svg", t.ansi2, null, `All ${c.total} checks passed`, `${pr.url}/checks`);
    const state = pr && (pr.draft && pr.state === "OPEN" ? "draft" : pr.state.toLowerCase());
    return h_flex().pl(23).gap(2).items_center()
      .when(Boolean(pr), (el) => el.child(chip("pr", "pull-request", tint, `#${pr.number}`, `${pr.title} (${state})`, pr.url)))
      .when(Boolean(checks), (el) => el.child(checks))
      .when(Boolean(ticket), (el) => el.child(chip("jira", "ticket", t.ansi4, ticket, `Open ${ticket} in Jira`, `${jira}/browse/${ticket}`)));
  }

  row({ w, i, g, tree, session, other }, t) {
    const on = w.active;
    const fromIndex = this.pressed === null ? -1 : spaces().findIndex(s => s.id === this.pressed);
    const colors = shared("space.colors") ?? {};
    const color = colors[w.id] ?? "ansi6";
    const fill = color.startsWith("#") ? color : (MARK[color] ?? t[color]);
    // Under its repo's header, a worktree named after the repo goes by its
    // session's name, else its branch. Under Other, the session follows the name.
    const label = g?.linked && g.name.toLowerCase() === w.name.toLowerCase() ? (session || g.branch || w.name) : w.name;
    const extra = other && session && session !== w.name ? session : null;
    const links = this.links(w, g, session, t);
    return v_flex()
      .relative()
      .id(`space-${w.id}`)
      .px(8)
      .h(rowHeight({ tree }) + (links ? 18 : 0))
      .gap(2)
      .flex_none()
      .justify_center()
      .rounded(8)
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .when(this.pressed === w.id && this.over !== w.id, (el) => el.opacity(0.5))
      .when(this.pressed !== null && this.over === w.id && this.pressed !== w.id, (el) => el.child(
        div().absolute().left(0).right(0).h(2).bg(t.accent)
          .when(fromIndex < i, line => line.bottom(0))
          .when(fromIndex > i, line => line.top(0)),
      ))
      .on_mouse_down("left", () => {
        this.pressed = w.id;
        this.over = w.id;
      })
      .on_mouse_move((_e, cx) => {
        const source = spaces().find(s => s.id === this.pressed);
        const over = source && (source.machine ?? null) === (w.machine ?? null) ? w.id : null;
        if (this.pressed !== null && this.over !== over) {
          this.over = over;
          cx.notify();
        }
      })
      .on_mouse_up("left", (_e, cx) => {
        const from = this.pressed;
        const over = this.over;
        this.pressed = null;
        this.over = null;
        if (from !== null && over === w.id && from !== w.id) {
          const index = spaces().findIndex(s => s.id === w.id);
          if (index !== -1) run("space.move", { id: from, index: index + 1 });
        } else if (from === w.id) run("space.select", { id: w.id });
        cx.notify();
      })
      .on_mouse_down("right", () => this.menu(w))
      .child(
        h_flex()
          .gap(9)
          .items_center()
          .when(Boolean(tree), el => el.pl(22).child(svg("mods/workspace-chrome/branch.svg").size(13).flex_none().text_color(t.dim)))
          .when(!tree, el => el.child(h_flex().size(18).flex_none().rounded(5).bg(fill).items_center().justify_center().text_size(10.5).font_bold().text_color("#ffffff").child(String(i + 1))))
          .child(div().flex_initial().min_w(SIDE_MIN).truncate().text_color(t.foreground).child(label))
          .child(g ? this.gitTail(g, true, label, t)
            : extra ? div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.dim).child(`· ${extra}`)
            : div().flex_1()),
      )
      .when(Boolean(links), (el) => el.child(links));
  }

  compact({ w, i }, t) {
    return railCell(h_flex()
      .id(`space-${w.id}`)
      .relative()
      .w(RAIL_CELL)
      .h(26)
      .rounded(6)
      .justify_center()
      .items_center()
      .when(w.active, (el) => el.bg(t.selected))
      .when(!w.active, (el) => el.hover((s) => s.bg(t.hover)))
      .on_click(() => run("space.select", { id: w.id }))
      .child(div().text_color(w.active ? t.foreground : t.muted).child(String(i + 1)))
      .child(div().absolute().right(5).text_color(tone(t, w.status)).child(glyph(w.status))));
  }

  render() {
    const t = theme();
    const collapsed = narrow();
    const palette = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];
    const sp = spaces();
    const ids = new Set(sp.map(p => p.id));
    const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
    let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
    for (const p of sp) {
      if (kept[p.id] || p.name === "~") continue;
      const uses = c => Object.values(kept).filter(v => v === c).length;
      kept[p.id] = palette.reduce((best, c) => uses(c) < uses(best) ? c : best);
      changed = true;
    }
    if (changed) setShared("space.colors", kept);
    const list = this.grouped(t, collapsed);
    // Bring the active space into view when it, or its place in the list, changes; a row already in view stays put.
    const active = sp.find(p => p.active)?.id;
    if (active !== this.revealed || this.activeAt !== this.revealedAt) {
      this.revealed = active;
      this.revealedAt = this.activeAt;
      if (this.activeAt >= 0) this.scroll.scroll_to_item(this.activeAt);
    }
    return v_flex().size_full().min_h(0).bg(t.chrome).text_size(13)
      .child(h_flex().h(31).pl(16).pr(10).items_center().justify_between().text_size(11.5).text_color(t.dim)
        .when(collapsed, el => el.pl(0).pr(0).justify_center())
        .when(!collapsed, el => el.child("Spaces"))
        .child(div().id("space-new").size(26).flex_none().flex().items_center().justify_center().rounded(6).hover(s => s.bg(t.hover).text_color(t.foreground))
          .on_click(() => run("space.new")).child(svg("mods/workspace-chrome/plus.svg").size(14))))
      .child(v_flex().flex_1().min_h(0).px(collapsed ? 0 : 8).pb(14).overflow_y_scrollbar().mode("always").track_scroll(this.scroll)
        // A block above (another mod's) growing, or the window resizing, shrinks this list and can push the active space out.
        .on_size_change((_size, cx) => { if (this.activeAt >= 0) { this.scroll.scroll_to_item(this.activeAt); cx.notify(); } })
        .on_mouse_up("left", (_e, cx) => { this.pressed = null; cx.notify(); })
        .children(list));
  }
}
