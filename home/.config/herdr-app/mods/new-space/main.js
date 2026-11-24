// Opened by cmd-shift-n (keys.json): pick a folder, then set it up like a new
// session in Claude desktop. A git repo gets a fresh worktree (see
// ~/dotfiles/bin/worktree-new), opened as a space whose shell is ready at once,
// with install and build running in a background "setup" tab. Any other
// folder becomes a plain space. new-space-here (cmd-n) does the same for the
// focused space's folder. Recent folders (repos by their main checkout) are
// listed first, sorted by path with a divider between parent folders: type to
// fuzzy filter them, then up/down and enter, or cmd-1-9, open one. The system
// picker only opens from a click or keypress, hence the button.
import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { closeOverlay, exec, home, notify, pickFolder, props, run, setShared, shared, spaces, theme } from "herdr";

const RECENT = "new-space.recent";
const KEEP = 50;
const SHOW = 8;

// Subsequence match, case-insensitive. Higher is better; null is no match.
// Rewards runs of adjacent letters, letters at word starts, and matches in
// the folder's own name over its parents.
function score(query, path) {
  const q = query.toLowerCase();
  const s = path.toLowerCase();
  const nameStart = s.lastIndexOf("/") + 1;
  let total = 0;
  let streak = 0;
  let from = 0;
  for (const c of q) {
    if (c === " ") continue;
    const i = s.indexOf(c, from);
    if (i < 0) return null;
    streak = i === from && from > 0 ? streak + 1 : 0;
    total += 1 + streak * 2;
    if (i === 0 || "/-_. ".includes(s[i - 1])) total += 3;
    if (i >= nameStart) total += 2;
    from = i + 1;
  }
  return total;
}

const parentOf = (folder) => folder.replace(/\/+$/, "").replace(/\/[^/]*$/, "") || "/";

// Without a query, the most recent folders sorted by parent then name, so
// siblings (all of ~/legend, say) sit together.
function filter(list, query) {
  if (!query.trim()) {
    return list.slice(0, SHOW).sort((a, b) =>
      parentOf(a).localeCompare(parentOf(b)) || a.localeCompare(b));
  }
  return list
    .map((folder, i) => ({ folder, i, s: score(query, folder.replace(home(), "~")) }))
    .filter((m) => m.s !== null)
    .sort((a, b) => b.s - a.s || a.i - b.i)
    .map((m) => m.folder)
    .slice(0, SHOW);
}

function recent() {
  const list = shared(RECENT);
  return Array.isArray(list) ? list : [];
}

function remember(folder) {
  setShared(RECENT, [folder, ...recent().filter((f) => f !== folder)].slice(0, KEEP));
}

function forget(folder) {
  setShared(RECENT, recent().filter((f) => f !== folder));
}

// Kept in step with new-space-here/main.js.
async function openSpace(folder) {
  const bin = `${home()}/dotfiles/bin`;
  const r = await exec(`${bin}/worktree-new`, [folder], { timeout: 180_000 });
  if (r.code === 2) {
    remember(folder);
    return run("space.new", { folder, machine: "" });
  }
  if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || "worktree-new failed");
  const wt = JSON.parse(r.stdout);
  remember(wt.main);
  const before = new Set(spaces().map((s) => s.id));
  // Named after the repo: left unnamed, Herdr would call it by its branch.
  run("space.new", { folder: wt.folder, name: wt.name, machine: "" });
  const space = spaces().find((s) => !before.has(s.id))?.id;
  run("tab.new", { space, name: "setup", folder: wt.folder, argv: [`${bin}/worktree-setup`, wt.main], focus: false });
}

export default class NewSpace extends View {
  init(_props, cx) {
    this.selected = 0;
    this.query = "";
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  // Closing the overlay ends this copy and its tasks, so it closes last.
  open(cx, folder) {
    if (this.busy) return;
    this.busy = true;
    cx.spawn(async (cx) => {
      const overlay = props()?.overlay;
      if (folder && (await exec("test", ["-d", folder])).code !== 0) {
        forget(folder);
        notify({ title: "Folder is gone", body: folder.replace(home(), "~"), level: "warning" });
        folder = null;
      } else if (!folder) {
        folder = await pickFolder({ prompt: "New space" });
      }
      if (folder) {
        this.status = "Making worktree…";
        cx.notify();
        try {
          await openSpace(folder);
        } catch (e) {
          notify({ title: "Couldn't make a worktree", body: String(e?.message ?? e), level: "error" });
        }
      }
      if (overlay) closeOverlay(overlay);
    });
  }

  shown() {
    return filter(recent(), this.query);
  }

  setQuery(query) {
    this.query = query;
    this.selected = 0;
  }

  key(e, cx) {
    if (this.busy) return;
    const list = this.shown();
    const n = list.length + 1; // the matching folders, then the button
    const k = e.keystroke;
    const m = e.modifiers ?? {};
    if (k === "down" || k === "ctrl-n") this.selected = (this.selected + 1) % n;
    else if (k === "up" || k === "ctrl-p") this.selected = (this.selected + n - 1) % n;
    else if (k === "enter") return this.open(cx, list[this.selected]);
    else if (/^cmd-[1-9]$/.test(k) && list[k.slice(4) - 1]) return this.open(cx, list[k.slice(4) - 1]);
    else if (k === "backspace") this.setQuery(this.query.slice(0, -1));
    else if (k === "alt-backspace") this.setQuery(this.query.replace(/[^\s/]*[\s/]*$/, ""));
    else if (k === "cmd-backspace" || k === "ctrl-u") this.setQuery("");
    else if (e.key_char && !m.control && !m.platform) this.setQuery(this.query + e.key_char);
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  render() {
    const t = theme();
    const list = this.shown();
    const grouped = !this.query.trim();
    const rows = list.flatMap((folder, i) => {
      const divider = grouped && i > 0 && parentOf(folder) !== parentOf(list[i - 1])
        ? [div().id(`divider-${i}`).h(1).mx(8).my(4).bg(t.input)]
        : [];
      const path = folder.replace(home(), "~");
      const name = path.split("/").pop() || path;
      const parent = path.slice(0, path.length - name.length - 1) || "/";
      return [...divider, h_flex().id(`recent-${i}`).gap(8).px(8).py(4).rounded(6).cursor_pointer()
        .when(i === this.selected, (s) => s.bg(t.selected))
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.open(cx, folder))
        .child(div().w(20).text_color(t.dim).child(i < 9 ? `⌘${i + 1}` : ""))
        .child(div().text_color(t.foreground).whitespace_nowrap().child(name))
        .child(div().flex_1().min_w(0).text_color(t.dim).truncate().child(parent))];
    });
    const button = this.selected === list.length;
    return v_flex().id("root").size_full().p(16).gap(12).text_size(13)
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .child(div().text_color(t.foreground).font_semibold().child("New space"))
      .when(recent().length > 0, (s) => s.child(h_flex().px(8).py(4).rounded(6).border_1().border_color(t.input)
        .child(this.query
          ? div().text_color(t.foreground).child(this.query + "▏")
          : div().text_color(t.dim).child("Type to filter recent folders"))))
      .when(rows.length > 0, (s) => s.child(v_flex().gap(2).children(rows)))
      .child(div().id("choose").px(12).py(6).rounded(6)
        .bg(button ? t.accent : t.input)
        .text_color(button ? t.accent_foreground : t.foreground)
        .hover((s) => s.bg(t.accent).text_color(t.accent_foreground))
        .on_click((_e, cx) => this.open(cx, null))
        .child(this.status ?? "Choose folder…"));
  }
}
