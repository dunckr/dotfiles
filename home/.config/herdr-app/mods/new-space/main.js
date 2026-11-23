// Opened by cmd-shift-n (keys.json): pick a folder, then set it up like a new
// session in Claude desktop. A git repo gets a fresh worktree (see
// ~/dotfiles/bin/worktree-new), opened as a space whose shell is ready at once,
// with install and build running in a background "setup" tab. Any other
// folder becomes a plain space. new-space-here (cmd-n) does the same for the
// focused space's folder. The system picker only opens from a click or
// keypress, hence the button.
import { View, div } from "gpui-kit";
import { v_flex } from "gpui-base";
import { closeOverlay, exec, home, notify, pickFolder, props, run, spaces, theme } from "herdr";

// Kept in step with new-space-here/main.js.
async function openSpace(folder) {
  const bin = `${home()}/dotfiles/bin`;
  const r = await exec(`${bin}/worktree-new`, [folder], { timeout: 180_000 });
  if (r.code === 2) return run("space.new", { folder, machine: "" });
  if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || "worktree-new failed");
  const wt = JSON.parse(r.stdout);
  const before = new Set(spaces().map((s) => s.id));
  // Named after the repo: left unnamed, Herdr would call it by its branch.
  run("space.new", { folder: wt.folder, name: wt.name, machine: "" });
  const space = spaces().find((s) => !before.has(s.id))?.id;
  run("tab.new", { space, name: "setup", folder: wt.folder, argv: [`${bin}/worktree-setup`, wt.main], focus: false });
}

export default class NewSpace extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  // Closing the overlay ends this copy and its tasks, so it closes last.
  pick(cx) {
    cx.spawn(async (cx) => {
      const overlay = props()?.overlay;
      const folder = await pickFolder({ prompt: "New space" });
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

  render() {
    const t = theme();
    return v_flex().id("root").size_full().p(16).gap(12).text_size(13)
      .track_focus(this.handle)
      .on_key_down((e, cx) => { if (e.keystroke === "enter") this.pick(cx); })
      .child(div().text_color(t.foreground).font_semibold().child("New space"))
      .child(div().id("choose").px(12).py(6).rounded(6).bg(t.solid).text_color(t.solid_foreground)
        .hover((s) => s.bg(t.accent))
        .on_click((_e, cx) => this.pick(cx))
        .child(this.status ?? "Choose folder…"));
  }
}
