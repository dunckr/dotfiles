// Opened by cmd-shift-n (keys.json): pick a folder, then set it up like a new
// session in Claude desktop. A git repo gets a fresh worktree (see
// ~/dotfiles/bin/worktree-new), opened as a space whose shell is ready at once,
// with install and build running in a background "setup" tab. Any other
// folder becomes a plain space. new-space-here (cmd-n) does the same for the
// focused space's folder. Recent folders (repos by their main checkout) are
// listed first: up/down and enter, or 1-9, open one. The system picker only
// opens from a click or keypress, hence the button.
import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { closeOverlay, exec, home, notify, pickFolder, props, run, setShared, shared, spaces, theme } from "herdr";

const RECENT = "new-space.recent";
const KEEP = 8;

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

  key(e, cx) {
    const list = recent();
    const n = list.length + 1; // the recent folders, then the button
    const k = e.keystroke;
    if (k === "down") this.selected = (this.selected + 1) % n;
    else if (k === "up") this.selected = (this.selected + n - 1) % n;
    else if (k === "enter") return this.open(cx, list[this.selected]);
    else if (/^[1-9]$/.test(k) && list[k - 1]) return this.open(cx, list[k - 1]);
    else return;
    cx.notify();
  }

  render() {
    const t = theme();
    const list = recent();
    const rows = list.map((folder, i) => {
      const path = folder.replace(home(), "~");
      const name = path.split("/").pop() || path;
      const parent = path.slice(0, path.length - name.length - 1) || "/";
      return h_flex().id(`recent-${i}`).gap(8).px(8).py(4).rounded(6).cursor_pointer()
        .when(i === this.selected, (s) => s.bg(t.selected))
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.open(cx, folder))
        .child(div().w(12).text_color(t.dim).child(i < 9 ? String(i + 1) : ""))
        .child(div().text_color(t.foreground).whitespace_nowrap().child(name))
        .child(div().flex_1().min_w(0).text_color(t.dim).truncate().child(parent));
    });
    const button = this.selected === list.length;
    return v_flex().id("root").size_full().p(16).gap(12).text_size(13)
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .child(div().text_color(t.foreground).font_semibold().child("New space"))
      .when(rows.length > 0, (s) => s.child(v_flex().gap(2).children(rows)))
      .child(div().id("choose").px(12).py(6).rounded(6)
        .bg(button ? t.accent : t.input)
        .text_color(button ? t.accent_foreground : t.foreground)
        .hover((s) => s.bg(t.accent).text_color(t.accent_foreground))
        .on_click((_e, cx) => this.open(cx, null))
        .child(this.status ?? "Choose folder…"));
  }
}
