import { Controller } from "@hotwired/stimulus";
import {
  computePosition,
  flip,
  shift,
  offset,
  autoUpdate,
} from "@floating-ui/dom";

export default class extends Controller {
  static targets = ["trigger", "content", "menuItem"];
  static values = {
    open: { type: Boolean, default: false },
    options: { type: Object, default: {} },
    // make content width match the trigger element (true/false)
    matchWidth: { type: Boolean, default: false },
  };

  connect() {
    this.openDelay = this.delayAt(0, 500);
    this.closeDelay = this.delayAt(1, 250);
    this.openTimeout = null;
    this.closeTimeout = null;
    this.cleanup = null;
    this.selectedIndex = -1;
    this.boundHandleKeydown = this.handleKeydown.bind(this);
    this.addEventListeners();
  }

  // Teardown that cannot fail comes first: a missing target throws, and Stimulus skips the rest.
  disconnect() {
    this.clearTimers();
    document.removeEventListener("keydown", this.boundHandleKeydown);
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
    this.removeEventListeners();
    // Nothing is left to wait for the exit animation, so apply the pending hide now.
    if (this.hasContentTarget) this.settleExit(this.contentTarget);
  }

  // Supports the tippy-style `delay` option: a number or a [open, close] tuple.
  delayAt(index, fallback) {
    const delay = this.optionsValue.delay;
    if (Array.isArray(delay)) return delay[index] ?? fallback;
    if (typeof delay === "number") return delay;
    return fallback;
  }

  addEventListeners() {
    this.triggerTarget.addEventListener("mouseenter", this.handleMouseEnter);
    this.triggerTarget.addEventListener("mouseleave", this.handleMouseLeave);
    this.triggerTarget.addEventListener("focusin", this.handleMouseEnter);
    this.triggerTarget.addEventListener("focusout", this.handleMouseLeave);
    this.contentTarget.addEventListener("mouseenter", this.handleMouseEnter);
    this.contentTarget.addEventListener("mouseleave", this.handleMouseLeave);
    this.contentTarget.addEventListener("focusin", this.handleMouseEnter);
    this.contentTarget.addEventListener("focusout", this.handleMouseLeave);
  }

  removeEventListeners() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.removeEventListener("mouseenter", this.handleMouseEnter);
      this.triggerTarget.removeEventListener("mouseleave", this.handleMouseLeave);
      this.triggerTarget.removeEventListener("focusin", this.handleMouseEnter);
      this.triggerTarget.removeEventListener("focusout", this.handleMouseLeave);
    }

    if (this.hasContentTarget) {
      this.contentTarget.removeEventListener("mouseenter", this.handleMouseEnter);
      this.contentTarget.removeEventListener("mouseleave", this.handleMouseLeave);
      this.contentTarget.removeEventListener("focusin", this.handleMouseEnter);
      this.contentTarget.removeEventListener("focusout", this.handleMouseLeave);
    }
  }

  handleMouseEnter = () => {
    this.clearTimers();
    this.openTimeout = setTimeout(() => this.show(), this.openDelay);
  };

  handleMouseLeave = () => {
    this.clearTimers();
    this.closeTimeout = setTimeout(() => this.hide(), this.closeDelay);
  };

  clearTimers() {
    clearTimeout(this.openTimeout);
    clearTimeout(this.closeTimeout);
  }

  show() {
    this.openValue = true;
    this.contentTarget.classList.remove("hidden");
    this.contentTarget.dataset.state = "open";
    if (this.matchWidthValue) {
      this.contentTarget.style.width = `${this.triggerTarget.offsetWidth}px`;
    }
    document.addEventListener("keydown", this.boundHandleKeydown);
    this.updatePosition();
  }

  hide() {
    this.openValue = false;
    document.removeEventListener("keydown", this.boundHandleKeydown);
    this.deselectAll();
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }

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
    if (this.cleanup) this.cleanup();

    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      computePosition(this.triggerTarget, this.contentTarget, {
        placement: this.optionsValue.placement || "bottom",
        middleware: [offset(4), flip(), shift({ padding: 8 })],
        // `fixed` positions against the viewport, so an ancestor with
        // `overflow: hidden` no longer clips the card.
        strategy: this.optionsValue.strategy || "absolute",
      }).then(({ x, y, placement }) => {
        Object.assign(this.contentTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
        this.contentTarget.dataset.side = placement.split("-")[0];
      });
    });
  }

  handleKeydown(e) {
    if (e.key === "Escape") {
      this.hide();
      return;
    }

    if (this.menuItemTargets.length === 0) return;

    if (e.key === "ArrowDown") {
      e.preventDefault();
      this.updateSelectedItem(1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this.updateSelectedItem(-1);
    } else if (e.key === "Enter" && this.selectedIndex !== -1) {
      e.preventDefault();
      this.menuItemTargets[this.selectedIndex].click();
    }
  }

  updateSelectedItem(direction) {
    this.menuItemTargets.forEach((item, index) => {
      if (item.getAttribute("aria-selected") === "true") {
        this.selectedIndex = index;
      }
    });

    if (this.selectedIndex >= 0) {
      this.toggleAriaSelected(this.menuItemTargets[this.selectedIndex], false);
    }

    this.selectedIndex += direction;

    if (this.selectedIndex < 0) {
      this.selectedIndex = this.menuItemTargets.length - 1;
    } else if (this.selectedIndex >= this.menuItemTargets.length) {
      this.selectedIndex = 0;
    }

    this.toggleAriaSelected(this.menuItemTargets[this.selectedIndex], true);
  }

  toggleAriaSelected(element, isSelected) {
    if (isSelected) {
      element.setAttribute("aria-selected", "true");
    } else {
      element.removeAttribute("aria-selected");
    }
  }

  deselectAll() {
    this.menuItemTargets.forEach((item) =>
      this.toggleAriaSelected(item, false)
    );
    this.selectedIndex = -1;
  }
}
