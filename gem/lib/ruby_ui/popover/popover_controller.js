import { Controller } from "@hotwired/stimulus";
import {
  computePosition,
  flip,
  shift,
  offset,
  autoUpdate,
} from "@floating-ui/dom";

export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = {
    open: { type: Boolean, default: false },
    options: { type: Object, default: {} },
    trigger: { type: String, default: "hover" },
  };

  connect() {
    this.closeTimeout = null;
    this.cleanup = null;
    this.addEventListeners();
    // openValue lives in the DOM, so a reconnect (frame swap, morph, moved element)
    // arrives already open. Re-arm the parts that live on the controller instead of
    // the markup — the keydown listener and the autoUpdate positioning.
    if (this.openValue) this.showPopover();
  }

  // Teardown that cannot fail comes first: resolving a target throws once the
  // element is gone, and Stimulus swallows that, skipping the rest of disconnect.
  disconnect() {
    clearTimeout(this.closeTimeout);
    document.removeEventListener("keydown", this.handleKeydown);
    document.removeEventListener("click", this.handleOutsideClick);
    this.stopAutoUpdate();
    this.removeElementEventListeners();
    // Nothing is left to wait for the exit animation, so apply the pending hide now.
    if (this.hasContentTarget) this.settleExit(this.contentTarget);
  }

  addEventListeners() {
    if (this.triggerValue === "hover") {
      this.triggerTarget.addEventListener("mouseenter", this.handleMouseEnter);
      this.triggerTarget.addEventListener("mouseleave", this.handleMouseLeave);
      this.contentTarget.addEventListener("mouseenter", this.handleMouseEnter);
      this.contentTarget.addEventListener("mouseleave", this.handleMouseLeave);
    } else if (this.triggerValue === "click") {
      this.triggerTarget.addEventListener("click", this.handleClick);
      document.addEventListener("click", this.handleOutsideClick);
    }
  }

  // Each target is guarded on its own: losing one of them must not strand the
  // listeners attached to the other.
  removeElementEventListeners() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.removeEventListener("mouseenter", this.handleMouseEnter);
      this.triggerTarget.removeEventListener("mouseleave", this.handleMouseLeave);
      this.triggerTarget.removeEventListener("click", this.handleClick);
    }

    if (this.hasContentTarget) {
      this.contentTarget.removeEventListener("mouseenter", this.handleMouseEnter);
      this.contentTarget.removeEventListener("mouseleave", this.handleMouseLeave);
    }
  }

  handleMouseEnter = () => {
    clearTimeout(this.closeTimeout);
    this.showPopover();
  };

  handleMouseLeave = () => {
    this.closeTimeout = setTimeout(() => this.hidePopover(), 100);
  };

  handleClick = (event) => {
    event.stopPropagation();
    this.openValue ? this.hidePopover() : this.showPopover();
  };

  handleOutsideClick = (event) => {
    if (this.element.contains(event.target)) return;
    if (!this.openValue) return;

    this.hidePopover();
  };

  handleKeydown = (event) => {
    if (event.key !== "Escape") return;
    if (!this.openValue) return;

    clearTimeout(this.closeTimeout);
    this.hidePopover();
  };

  // openValue is set here rather than by the callers, so a guarded early return can
  // never leave the DOM claiming the popover is open while nothing is wired up.
  showPopover() {
    if (!this.hasTriggerTarget || !this.hasContentTarget) return;

    const wasOpen = this.openValue;
    this.openValue = true;
    this.contentTarget.classList.remove("hidden");
    this.contentTarget.dataset.state = "open";
    document.addEventListener("keydown", this.handleKeydown);
    this.updatePosition();
    // Lets a composite (DatePicker) follow the state: aria-expanded, focus.
    // Only on the closed -> open transition: hover re-entering an open popover
    // (or a reconnect) must not look like a new open.
    if (!wasOpen) this.dispatch("show");
  }

  // Same rule as disconnect(): release what is held outside the element first, so a
  // missing content target cannot leave the keydown listener or autoUpdate running.
  hidePopover() {
    const wasOpen = this.openValue;
    this.openValue = false;
    document.removeEventListener("keydown", this.handleKeydown);
    this.stopAutoUpdate();
    if (wasOpen) this.dispatch("hide");

    if (!this.hasContentTarget) return;

    this.contentTarget.dataset.state = "closed";
    this.hideAfterExitAnimation(this.contentTarget);
  }

  afterExit(content) {
    content.classList.add("hidden");
  }

  // Overlay exit — the same block in every overlay controller, so keep them in sync.
  exitAnimationNames = new WeakMap();

  hideAfterExitAnimation(animated) {
    const exitAnimations = animated
      .getAnimations()
      .filter((animation) => animation instanceof CSSAnimation);

    // No exit animation, or no box to run it in: animationend would never fire.
    if (exitAnimations.length === 0) {
      this.settleExit(animated);
      return;
    }

    this.exitAnimationNames.set(animated, exitAnimations.map((animation) => animation.animationName));
    animated.addEventListener("animationend", this.handleExitAnimationEnd);
    animated.addEventListener("animationcancel", this.handleExitAnimationEnd);
  }

  handleExitAnimationEnd = (event) => {
    // animationend bubbles — an animated child must not hide its container.
    if (event.target !== event.currentTarget) return;
    // Closing mid-open cancels the enter animation; only the exit run settles this.
    if (!this.exitAnimationNames.get(event.currentTarget)?.includes(event.animationName)) return;

    this.settleExit(event.currentTarget);
  };

  settleExit(animated) {
    animated.removeEventListener("animationend", this.handleExitAnimationEnd);
    animated.removeEventListener("animationcancel", this.handleExitAnimationEnd);
    // Reopened mid-exit: it is on its way back in, leave it visible.
    if (animated.dataset.state !== "closed") return;

    this.afterExit(animated);
  }

  updatePosition() {
    this.stopAutoUpdate();

    // Hold the exact pair this run positions. A target can be detached or swapped
    // while the controller stays connected, and the stale element must not be
    // written to by an observer callback or an in-flight computePosition.
    const trigger = this.triggerTarget;
    const content = this.contentTarget;

    // Deferred teardown is bound to this run's own handle, so a newer positioning
    // run installed before the microtask drains is never torn down by an older one.
    let stop = null;
    const releaseThisRun = () => {
      stop?.();
      if (this.cleanup === stop) this.cleanup = null;
    };

    stop = autoUpdate(trigger, content, () => {
      if (!trigger.isConnected || !content.isConnected) {
        // Release the observers instead of throwing on every scroll and resize.
        // Deferred because autoUpdate runs this once synchronously, before the
        // handle below has been assigned.
        queueMicrotask(releaseThisRun);
        return;
      }

      computePosition(trigger, content, {
        placement: this.optionsValue.placement || "bottom",
        middleware: [flip(), shift(), offset(8)],
      }).then(({ x, y, placement }) => {
        if (!content.isConnected) return;

        Object.assign(content.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
        // flip() can resolve to the opposite side of the requested placement,
        // so the directional slide-in classes must follow the resolved value.
        content.dataset.side = placement.split("-")[0];
      });
    });

    this.cleanup = stop;
  }

  stopAutoUpdate() {
    if (!this.cleanup) return;

    this.cleanup();
    this.cleanup = null;
  }
}
