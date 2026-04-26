import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, shift } from "@floating-ui/dom";

export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = { placement: String }

  constructor(...args) {
    super(...args);
    this.cleanup;
  }

  connect() {
    this.setFloatingElement();

    const tooltipId = this.contentTarget.getAttribute("id");
    this.triggerTarget.setAttribute("aria-describedby", tooltipId);

  }

  disconnect() {
    this.cleanup();
  }

  setFloatingElement() {
    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      computePosition(this.triggerTarget, this.contentTarget, {
        placement: this.placementValue,
        middleware: [offset(4), shift()]
      }).then(({ x, y }) => {
        Object.assign(this.contentTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
      });
    });
  }
}
