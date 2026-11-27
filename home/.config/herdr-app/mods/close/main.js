// Opened by cmd-w (keys.json): closes what you mean in one press, and asks first
// whenever that ends work.
// - A space whose other tabs are only idle shells (the "setup" tab once install is
//   done): the whole space, with one question.
// - Otherwise the shown tab, asking first when it runs an agent or a program.
//   An idle shell tab closes at once, like a terminal window.
// cmd-alt-w still closes the space whatever it holds, cmd-shift-w the pane.
// The question is asked here, in this overlay, rather than through Herdr's confirm
// mod: a dialog opened from here lost the keyboard when this overlay closed.
// Enter confirms; Esc, or cmd-w again (it toggles this overlay), cancels.
import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { agents, checking, closeOverlay, focused, panes, props, run, spaces, theme } from "herdr";
import { plan } from "./plan.js";

export default class Close extends View {
  init(_props, cx) {
    // `herdr-app check` runs init for real: it must not close anything.
    if (checking()) return;
    const f = focused();
    const space = spaces().find((s) => s.id === f?.space) ?? spaces().find((s) => s.active);
    const tab = space?.tabs.find((t) => t.id === f?.tab) ?? space?.tabs.find((t) => t.active);
    this.plan = plan(space, tab, panes(), agents());
    if (this.plan?.ask) {
      this.handle = cx.focus_handle();
      this.handle.focus();
      return;
    }
    if (this.plan) run(this.plan.command, this.plan.args);
    this.done();
  }

  done() {
    const overlay = props()?.overlay;
    if (overlay) closeOverlay(overlay);
  }

  // Closing the overlay ends this copy, so the command runs first.
  yes() {
    run(this.plan.command, this.plan.args);
    this.done();
  }

  render() {
    const t = theme();
    const ask = this.plan?.ask;
    if (!ask) return div();
    const button = (id, label, bg, fg, onClick) =>
      h_flex().id(id).h(32).px(14).items_center().rounded(8).border_1().border_color(id === "no" ? t.input : bg).bg(bg).text_color(fg).cursor_pointer().hover((s) => s.opacity(0.88)).on_click(onClick).child(label);
    return v_flex()
      .id("close")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (e.key === "enter") this.yes();
        else if (e.key === "escape") this.done();
        else return;
        cx.stop_propagation();
      })
      .size_full()
      .min_h(0)
      .p(18)
      .gap(12)
      .rounded(8)
      .bg(t.popover)
      .text_size(13)
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child(ask.title)).child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(div().flex_1().min_h(0).text_color(t.muted).child(ask.detail))
      .child(h_flex().justify_end().gap(8).text_size(12)
        .child(button("no", "Cancel", t.raised, t.foreground, () => this.done()))
        .child(button("yes", "Close", t.solid, t.solid_foreground, () => this.yes())));
  }
}
