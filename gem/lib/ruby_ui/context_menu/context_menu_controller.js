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
    this.cleanup = null;
    this.selectedIndex = -1;
    this.boundHandleKeydown = this.handleKeydown.bind(this);
  }

  disconnect() {
    this.hide();
  }

  handleContextMenu(event) {
    event.preventDefault();
    this.open();
  }

  open() {
    this.openValue = true;
    this.contentTarget.classList.remove("hidden");
    if (this.matchWidthValue) {
      this.contentTarget.style.width = `${this.triggerTarget.offsetWidth}px`;
    }
    this.addEventListeners();
    this.updatePosition();
  }

  close() {
    this.hide();
  }

  hide() {
    if (!this.openValue) return;
    this.openValue = false;
    this.contentTarget.classList.add("hidden");
    this.removeEventListeners();
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
        placement: this.optionsValue.placement || "bottom-start",
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

  addEventListeners() {
    document.addEventListener("keydown", this.boundHandleKeydown);
    document.addEventListener("click", this.handleOutsideClick);
  }

  removeEventListeners() {
    document.removeEventListener("keydown", this.boundHandleKeydown);
    document.removeEventListener("click", this.handleOutsideClick);
  }

  handleOutsideClick = (event) => {
    if (!this.element.contains(event.target)) {
      this.hide();
    }
  };

  handleKeydown(e) {
    if (e.key === "Escape") {
      e.preventDefault();
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
