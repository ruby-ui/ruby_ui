import { Controller } from "@hotwired/stimulus"
import { computePosition, flip, shift } from "@floating-ui/dom";

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = ['trigger', 'source', 'successPopover', 'errorPopover']
  static values = {
    options: {
      type: Object,
      default: {},
    },
  }

  copy() {
    let sourceElement = this.sourceTarget.children[0];
    if (!sourceElement) {
      this.showErrorPopover();
      return;
    }
    let textToCopy = sourceElement.tagName === 'INPUT' ? sourceElement.value : sourceElement.innerText;
    navigator.clipboard.writeText(textToCopy).then(() => {
      this.#showSuccessPopover();
    }).catch(() => {
      this.#showErrorPopover();
    })
  }

  onClickOutside() {
    if (!this.successPopoverTarget.classList.contains("hidden")) this.successPopoverTarget.classList.add("hidden");
    if (!this.errorPopoverTarget.classList.contains("hidden")) this.errorPopoverTarget.classList.add("hidden");
  }

  #computeTooltip(popoverElement) {
    computePosition(this.triggerTarget, popoverElement, {
      placement: this.optionsValue.placement || "top",
      middleware: [flip(), shift()],
    }).then(({ x, y }) => {
      Object.assign(popoverElement.style, {
        left: `${x}px`,
        top: `${y}px`,
      });
    });
  }

  #showSuccessPopover() {
    this.#computeTooltip(this.successPopoverTarget);
    this.successPopoverTarget.classList.remove("hidden");
  }

  #showErrorPopover() {
    this.#computeTooltip(this.errorPopoverTarget);
    this.errorPopoverTarget.classList.remove("hidden");
  }
}
