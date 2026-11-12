// Opened by cmd-n (keys.json): pick a folder, then set it up like a new
// session in Claude desktop. A git repo gets a fresh worktree off main on a
// generated branch (in Herdr's worktree folder, so the sidebar nests it under the repo);
// any other folder becomes a plain space. The system picker only opens from
// a click or keypress, hence the button.
import { View, div } from "gpui-kit";
import { v_flex } from "gpui-base";
import { closeOverlay, exec, home, notify, pickFolder, props, run, theme } from "herdr";

const ADJECTIVES = ["brave", "calm", "clever", "eager", "gentle", "happy", "keen", "lucky", "quiet", "swift", "witty", "bold"];
const NOUNS = ["otter", "falcon", "maple", "comet", "harbor", "willow", "ember", "lynx", "pebble", "heron", "cedar", "orbit"];
const pick = (list) => list[Math.floor(Math.random() * list.length)];

const git = (cwd, args) => exec("git", args, { cwd, timeout: 600_000 }).catch(() => null);

async function newWorktree(folder) {
  const common = await git(folder, ["rev-parse", "--path-format=absolute", "--git-common-dir"]);
  if (common?.code !== 0) return null;
  // The main checkout holds the shared .git folder, so it names the repo.
  const repo = common.stdout.trim().replace(/\/\.git\/?$/, "").split("/").pop();
  for (let i = 0; i < 5; i++) {
    const branch = `${pick(ADJECTIVES)}-${pick(NOUNS)}`;
    const path = `${home()}/.herdr/worktrees/${repo}/${branch}`;
    const r = await git(folder, ["worktree", "add", "-b", branch, path, "main"]);
    if (r?.code === 0) return { folder: path, name: repo };
    if (!/already exists/.test(r?.stderr ?? "")) throw new Error(r?.stderr?.trim() || "git worktree add failed");
  }
  throw new Error("no free branch name");
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
        this.status = "Setting up…";
        cx.notify();
        try {
          // Named after the repo: left unnamed, Herdr would call it by its branch.
          const worktree = await newWorktree(folder);
          run("space.new", { folder: worktree?.folder ?? folder, name: worktree?.name, machine: "" });
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
