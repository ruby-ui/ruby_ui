import { Controller } from "@hotwired/stimulus"
import tippy from "tippy.js";

export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = {
    options: {
      type: Object,
      default: {},
    }
  }

  connect() {
    this.initializeTippy();
  }

  disconnect() {
    this.destroyTippy();
  }

  initializeTippy() {
    const defaultOptions = {
      content: this.contentTarget.innerHTML,
      allowHTML: true,
      interactive: true,
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
}
