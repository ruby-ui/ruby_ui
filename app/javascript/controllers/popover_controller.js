import { Controller } from "@hotwired/stimulus";
import tippy from "tippy.js";

export default class extends Controller {
  static targets = ["trigger", "content", "menuItem"];
  static values = {
    options: {
      type: Object,
      default: {},
    }
  }

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this); // Bind the function so we can remove it later
    this.initializeTippy();
    this.selectedIndex = -1;
  }

  disconnect() {
    this.destroyTippy();
  }

  initializeTippy() {
    const defaultOptions = {
      content: this.contentTarget.innerHTML,
      allowHTML: true,
      interactive: true,
      onShow: () => {
        this.addEventListeners();
      },
      onHide: () => {
        this.removeEventListeners();
        this.deselectAll();
      }
    };

    const mergedOptions = { ...this.optionsValue, ...defaultOptions };
    this.tippy = tippy(this.triggerTarget, mergedOptions);
  }

  destroyTippy() {
    if (this.tippy) {
      this.tippy.destroy();
    }
  }

  handleContextMenu(event) {
    event.preventDefault();
    this.open();
  }

  open() {
    this.tippy.show();
  }

  close() {
    this.tippy.hide();
  }

  handleKeydown(e) {
    // return if no menu items (one line fix for)
    if (this.menuItemTargets.length === 0) { return; }

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      this.updateSelectedItem(1);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      this.updateSelectedItem(-1);
    } else if (e.key === 'Enter' && this.selectedIndex !== -1) {
      e.preventDefault();
      this.menuItemTargets[this.selectedIndex].click();
    }
  }

  updateSelectedItem(direction) {
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
    // Add or remove attribute
    if (isSelected) {
      element.setAttribute('aria-selected', 'true');
    } else {
      element.removeAttribute('aria-selected');
    }
  }

  deselectAll() {
    this.menuItemTargets.forEach(item => this.toggleAriaSelected(item, false));
    this.selectedIndex = -1;
  }

  addEventListeners() {
    document.addEventListener('keydown', this.boundHandleKeydown);
  }

  removeEventListeners() {
    document.removeEventListener('keydown', this.boundHandleKeydown);
  }
}
