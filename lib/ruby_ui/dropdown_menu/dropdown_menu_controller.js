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
    open: {
      type: Boolean,
      default: false,
    },
    options: {
      type: Object,
      default: {},
    },
  };

  connect() {
    this.boundHandleKeydown = this.#handleKeydown.bind(this); // Bind the function so we can remove it later
    this.selectedIndex = -1;

    this.#setupAutoUpdate();
  }

  disconnect() {
    if (this.autoUpdateCleanup) {
      this.autoUpdateCleanup();
    }
  }

  #setupAutoUpdate() {
    this.autoUpdateCleanup = autoUpdate(
      this.triggerTarget,
      this.contentTarget,
      this.#computeTooltip.bind(this),
    );
  }

  #computeTooltip() {
    computePosition(this.triggerTarget, this.contentTarget, {
      placement: this.optionsValue.placement || "top",
      middleware: [flip(), shift(), offset(8)],
      strategy: this.optionsValue.strategy || "absolute",
    }).then(({ x, y }) => {
      Object.assign(this.contentTarget.style, {
        left: `${x}px`,
        top: `${y}px`,
      });
    });
  }

  onClickOutside(event) {
    if (!this.openValue) return;
    if (this.element.contains(event.target)) return;

    event.preventDefault();
    this.close();
  }

  toggle() {
    this.contentTarget.classList.contains("hidden")
      ? this.#open()
      : this.close();
  }

  #open() {
    this.openValue = true;
    this.#deselectAll();
    this.#addEventListeners();
    this.#computeTooltip();
    this.contentTarget.classList.remove("hidden");
  }

  close() {
    this.openValue = false;
    this.#removeEventListeners();
    this.contentTarget.classList.add("hidden");
  }

  #handleKeydown(e) {
    // return if no menu items (one line fix for)
    if (this.menuItemTargets.length === 0) {
      return;
    }

    if (e.key === "ArrowDown") {
      e.preventDefault();
      this.#updateSelectedItem(1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this.#updateSelectedItem(-1);
    } else if (e.key === "Enter" && this.selectedIndex !== -1) {
      e.preventDefault();
      this.menuItemTargets[this.selectedIndex].click();
    }
  }

  #updateSelectedItem(direction) {
    // Check if any of the menuItemTargets have aria-selected="true" and set the selectedIndex to that index
    this.menuItemTargets.forEach((item, index) => {
      if (item.getAttribute("aria-selected") === "true") {
        this.selectedIndex = index;
      }
    });

    if (this.selectedIndex >= 0) {
      this.#toggleAriaSelected(this.menuItemTargets[this.selectedIndex], false);
    }

    this.selectedIndex += direction;

    if (this.selectedIndex < 0) {
      this.selectedIndex = this.menuItemTargets.length - 1;
    } else if (this.selectedIndex >= this.menuItemTargets.length) {
      this.selectedIndex = 0;
    }

    this.#toggleAriaSelected(this.menuItemTargets[this.selectedIndex], true);
  }

  #toggleAriaSelected(element, isSelected) {
    // Add or remove attribute
    if (isSelected) {
      element.setAttribute("aria-selected", "true");
    } else {
      element.removeAttribute("aria-selected");
    }
  }

  #deselectAll() {
    this.menuItemTargets.forEach((item) =>
      this.#toggleAriaSelected(item, false),
    );
    this.selectedIndex = -1;
  }

  #addEventListeners() {
    document.addEventListener("keydown", this.boundHandleKeydown);
  }

  #removeEventListeners() {
    document.removeEventListener("keydown", this.boundHandleKeydown);
  }
}
