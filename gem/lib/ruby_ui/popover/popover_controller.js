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
  }

  disconnect() {
    this.removeEventListeners();
    clearTimeout(this.closeTimeout);
    document.removeEventListener("keydown", this.handleKeydown);
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
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

  removeEventListeners() {
    this.triggerTarget.removeEventListener("mouseenter", this.handleMouseEnter);
    this.triggerTarget.removeEventListener("mouseleave", this.handleMouseLeave);
    this.contentTarget.removeEventListener("mouseenter", this.handleMouseEnter);
    this.contentTarget.removeEventListener("mouseleave", this.handleMouseLeave);
    this.triggerTarget.removeEventListener("click", this.handleClick);
    document.removeEventListener("click", this.handleOutsideClick);
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
    this.contentTarget.classList.remove("hidden");
    this.contentTarget.dataset.state = "open";
    document.addEventListener("keydown", this.handleKeydown);
    this.updatePosition();
  }

  hidePopover() {
    this.contentTarget.classList.add("hidden");
    this.contentTarget.dataset.state = "closed";
    document.removeEventListener("keydown", this.handleKeydown);
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
  }

  updatePosition() {
    if (this.cleanup) {
      this.cleanup();
    }

    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
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
