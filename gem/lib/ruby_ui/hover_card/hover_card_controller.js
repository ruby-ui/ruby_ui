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

  disconnect() {
    this.removeEventListeners();
    this.clearTimers();
    document.removeEventListener("keydown", this.boundHandleKeydown);
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
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
  }

  removeEventListeners() {
    this.triggerTarget.removeEventListener("mouseenter", this.handleMouseEnter);
    this.triggerTarget.removeEventListener("mouseleave", this.handleMouseLeave);
    this.triggerTarget.removeEventListener("focusin", this.handleMouseEnter);
    this.triggerTarget.removeEventListener("focusout", this.handleMouseLeave);
    this.contentTarget.removeEventListener("mouseenter", this.handleMouseEnter);
    this.contentTarget.removeEventListener("mouseleave", this.handleMouseLeave);
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
    if (this.matchWidthValue) {
      this.contentTarget.style.width = `${this.triggerTarget.offsetWidth}px`;
    }
    document.addEventListener("keydown", this.boundHandleKeydown);
    this.updatePosition();
  }

  hide() {
    this.openValue = false;
    this.contentTarget.classList.add("hidden");
    document.removeEventListener("keydown", this.boundHandleKeydown);
    this.deselectAll();
    if (this.cleanup) {
      this.cleanup();
      this.cleanup = null;
    }
  }

  updatePosition() {
    if (this.cleanup) this.cleanup();

    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      computePosition(this.triggerTarget, this.contentTarget, {
        placement: this.optionsValue.placement || "bottom",
        middleware: [offset(4), flip(), shift({ padding: 8 })],
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
    } else if (e.key === "Escape") {
      this.hide();
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
