// Opened by cmd-n (keys.json): a new space on a fresh worktree of the repo the
// focused space is in, like new-space (cmd-shift-n) without the folder picker.
// Outside a git repo it opens a plain space in the same folder.
import { View, div } from "gpui-kit";
import { v_flex } from "gpui-base";
import { closeOverlay, exec, focused, home, notify, panes, props, run, spaces, theme } from "herdr";

// Kept in step with new-space/main.js.
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

// The focused terminal's live folder, else the shown space's first terminal's,
// else the folder it was made in.
function currentFolder() {
  const f = focused();
  if (f?.cwd) return f.cwd;
  const space = spaces().find((s) => s.id === f?.space) ?? spaces().find((s) => s.active);
  if (!space) return null;
  const tabs = new Set(space.tabs.map((t) => t.id));
  return panes().find((p) => tabs.has(p.tab) && p.cwd)?.cwd || space.folder || null;
}

export default class NewSpaceHere extends View {
  init(_props, cx) {
    const folder = currentFolder();
    this.status = folder ? `New worktree of ${folder.replace(home(), "~")}…` : "No folder to copy";
    cx.spawn(async () => {
      if (folder) {
        try {
          await openSpace(folder);
        } catch (e) {
          notify({ title: "Couldn't make a worktree", body: String(e?.message ?? e), level: "error" });
        }
      }
      // Closing the overlay ends this copy and its tasks, so it closes last.
      const overlay = props()?.overlay;
      if (overlay) closeOverlay(overlay);
    });
  }

  render() {
    const t = theme();
    return v_flex().id("root").size_full().p(16).gap(8).text_size(13)
      .child(div().text_color(t.foreground).font_semibold().child("New space"))
      .child(div().text_color(t.dim).child(this.status));
  }
}
