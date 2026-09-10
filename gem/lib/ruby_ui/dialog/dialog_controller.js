import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--dialog"
export default class extends Controller {
  static targets = ["dialog"];
  static values = {
    open: {
      type: Boolean,
      default: false,
    },
  };

  connect() {
    this.dialogTarget.addEventListener("close", this.handleClose);
    this.dialogTarget.addEventListener("cancel", this.handleCancel);
    if (this.openValue) {
      this.open();
    }
  }

  disconnect() {
    // The <dialog> may already be gone; the scroll lock must be lifted either way.
    if (this.hasDialogTarget) {
      this.dialogTarget.removeEventListener("close", this.handleClose);
      this.dialogTarget.removeEventListener("cancel", this.handleCancel);
      // Nothing is left to wait for the exit animation, so apply the pending close now.
      this.settleExit(this.dialogTarget);
    }
    // Removed while open, the dialog fires no close event; the lock must not outlive it.
    this.releaseScrollLock();
  }

  open(e) {
    e?.preventDefault();
    this.dialogTarget.dataset.state = "open";
    // Reopened mid-exit the dialog is still open; showModal() on an open dialog throws in older browsers.
    if (!this.dialogTarget.open) this.dialogTarget.showModal();
    document.body.classList.add("overflow-hidden");
  }

  dismiss() {
    if (this.dialogTarget.dataset.state === "closed") return;

    this.dialogTarget.dataset.state = "closed";
    this.hideAfterExitAnimation(this.dialogTarget);
  }

  afterExit() {
    this.dialogTarget.close();
  }

  backdropClick(e) {
    if (e.target === this.dialogTarget) {
      this.dismiss();
    }
  }

  // Escape (and requestClose()) fire cancel; route it through the exit animation.
  handleCancel = (e) => {
    // A cancelled file picker inside the dialog bubbles its own cancel event.
    if (e.target !== this.dialogTarget) return;
    // Already on its way out: let a second Escape close natively where the browser allows it.
    if (this.dialogTarget.dataset.state === "closed") return;

    e.preventDefault();
    this.dismiss();
  };

  handleClose = () => {
    this.releaseScrollLock();
    // A close this controller did not start (a second Escape mid-exit) must not leave a pending exit behind.
    this.settleExit(this.dialogTarget);
  };

  // A nested Dialog or a Sheet may still be open underneath; the page stays locked for it.
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
      // A later dismiss or close owns the dialog now; this run is stale.
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
