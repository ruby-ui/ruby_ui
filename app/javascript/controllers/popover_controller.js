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

  initializeTippy() {
    const defaultOptions = {
      content: this.contentTarget.innerHTML,
      allowHTML: true,
      interactive: true,
    };

    const mergedOptions = { ...this.optionsValue, ...defaultOptions };

    tippy(this.triggerTarget, mergedOptions);
  }
}
