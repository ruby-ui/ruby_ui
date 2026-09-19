import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--sheet-content" on the <dialog>; ruby-ui--sheet opens it.
export default class extends Controller {
  connect() {
    this.element.addEventListener("cancel", this.handleCancel);
    this.element.addEventListener("close", this.handleClose);
  }

  disconnect() {
    this.element.removeEventListener("cancel", this.handleCancel);
    this.element.removeEventListener("close", this.handleClose);
    // Nothing is left to wait for the exit animation, so apply the pending close now.
    this.settleExit(this.element);
    // Removed while open, the dialog fires no close event; the lock must not outlive it.
    this.releaseScrollLock();
  }

  close() {
    if (this.element.dataset.state === "closed") return;

    this.element.dataset.state = "closed";
    this.hideAfterExitAnimation(this.element);
  }

  afterExit() {
    this.element.close();
  }

  // A click on the ::backdrop targets the dialog, but so does one on the panel's own padding: hit-test the box.
  backdropClick(e) {
    if (e.target === this.element && !this.coversPoint(e.clientX, e.clientY)) this.close();
  }

  coversPoint(x, y) {
    const { top, right, bottom, left } = this.element.getBoundingClientRect();
    return left <= x && x <= right && top <= y && y <= bottom;
  }

  // Escape (and requestClose()) fire cancel; route it through the exit animation.
  handleCancel = (e) => {
    // A cancelled file picker inside the sheet bubbles its own cancel event.
    if (e.target !== this.element) return;
    // Already on its way out: let a second Escape close natively where the browser allows it.
    if (this.element.dataset.state === "closed") return;

    e.preventDefault();
    this.close();
  };

  handleClose = () => {
    this.releaseScrollLock();
    // A close this controller did not start (a second Escape mid-exit) must not leave a pending exit behind.
    this.settleExit(this.element);
  };

  // A nested Sheet or a Dialog may still be open underneath; the page stays locked for it.
  releaseScrollLock() {
    if (document.querySelector("dialog:modal")) return;

    document.body.classList.remove("overflow-hidden");
  }

  // Overlay exit — unlike the other overlays this waits on the Animation objects: the ::backdrop animates too,
  // and its events land on the <dialog> under the same keyframe names as the panel's.
  hideAfterExitAnimation(animated) {
    const run = (this.exitRun = {});
    // subtree: true is what lists the ::backdrop's animation; descendants are filtered back out.
    const exitAnimations = animated
      .getAnimations({ subtree: true })
      .filter((animation) => animation instanceof CSSAnimation && animation.effect?.target === animated);

    // No exit animation, or no box to run it in: nothing would ever finish.
    if (exitAnimations.length === 0) {
      this.settleExit(animated);
      return;
    }

    // A cancelled exit (reopened mid-exit) counts as finished too.
    Promise.allSettled(exitAnimations.map((animation) => animation.finished)).then(() => {
      // A later close owns the dialog now; this run is stale.
      if (this.exitRun !== run) return;

      this.settleExit(animated);
    });
  }

  settleExit(animated) {
    this.exitRun = null;
    // Reopened mid-exit: it is on its way back in, leave it visible.
    if (animated.dataset.state !== "closed") return;

    this.afterExit(animated);
  }
}
