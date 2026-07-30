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
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
    this.removeElementEventListeners();
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
    this.openValue = true;
    this.showPopover();
  };

  handleMouseLeave = () => {
    this.closeTimeout = setTimeout(() => {
      this.openValue = false;
      this.hidePopover();
    }, 100);
  };

  handleClick = (event) => {
    event.stopPropagation();
    this.openValue = !this.openValue;
    this.openValue ? this.showPopover() : this.hidePopover();
  };

  handleOutsideClick = (event) => {
    if (!this.element.contains(event.target) && this.openValue) {
      this.openValue = false;
      this.hidePopover();
    }
  };

  handleKeydown = (event) => {
    if (event.key !== "Escape") return;
    if (!this.openValue) return;

    clearTimeout(this.closeTimeout);
    this.openValue = false;
    this.hidePopover();
  };

  showPopover() {
    if (!this.hasTriggerTarget || !this.hasContentTarget) return;

    this.contentTarget.classList.remove("hidden");
    this.contentTarget.dataset.state = "open";
    document.addEventListener("keydown", this.handleKeydown);
    this.updatePosition();
  }

  // Same rule as disconnect(): release what is held outside the element first, so a
  // missing content target cannot leave the keydown listener or autoUpdate running.
  hidePopover() {
    document.removeEventListener("keydown", this.handleKeydown);
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }

    if (!this.hasContentTarget) return;

    this.contentTarget.classList.add("hidden");
    this.contentTarget.dataset.state = "closed";
  }

  updatePosition() {
    if (this.cleanup) {
      this.cleanup();
    }

    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      // autoUpdate keeps firing on scroll/resize; bail out rather than throw once
      // a target is gone and nothing has torn the popover down yet.
      if (!this.hasTriggerTarget || !this.hasContentTarget) return;

      computePosition(this.triggerTarget, this.contentTarget, {
        placement: this.optionsValue.placement || "bottom",
        middleware: [flip(), shift(), offset(8)],
      }).then(({ x, y, placement }) => {
        Object.assign(this.contentTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
        // flip() can resolve to the opposite side of the requested placement,
        // so the directional slide-in classes must follow the resolved value.
        this.contentTarget.dataset.side = placement.split("-")[0];
      });
    });
  }
}
