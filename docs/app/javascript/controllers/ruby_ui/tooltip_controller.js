import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, shift } from "@floating-ui/dom";

export default class extends Controller {
  static targets = ["trigger", "content"];

  static values = { placement: "top" };

  mount() {
    if (this.mounted) return;

    const element = this.cloneTemplate();
    element.setAttribute("data-placement", this.placementValue);
    document.body.appendChild(element);

    this.triggerTarget.setAttribute("aria-describedby", element.id);
    element.addEventListener("animationend", (event) => this.animationEnd(event));

    const onBeforeCache = () => this.unmount();
    document.addEventListener("turbo:before-cache", onBeforeCache);

    this.mounted = { element, onBeforeCache };
    this.mounted.stopAutoUpdate = autoUpdate(this.triggerTarget, element, () => this.reposition());
  }

  unmount() {
    if (!this.mounted) return;

    document.removeEventListener("turbo:before-cache", this.mounted.onBeforeCache);

    this.mounted.stopAutoUpdate?.();
    this.mounted.element.remove();
    this.triggerTarget.removeAttribute("aria-describedby");

    this.mounted = null;
  }

  disconnect() {
    this.unmount();
  }

  show() {
    if (!this.hasContentTarget) return;

    this.mount();
    this.mounted.element.setAttribute("data-state", "open");
  }

  hide() {
    this.mounted?.element.setAttribute("data-state", "closed");
  }

  animationEnd(event) {
    if (event.animationName !== "exit") return;
    if (this.mounted?.element.getAttribute("data-state") !== "closed") return;

    this.unmount();
  }

  cloneTemplate() {
    return this.contentTarget.content.firstElementChild.cloneNode(true);
  }

  reposition() {
    if (!this.mounted) return;

    const position = { placement: this.placementValue, middleware: [offset(4), shift()] };

    computePosition(this.triggerTarget, this.mounted.element, position).then(({ x, y }) => {
      this.mounted?.element.style.setProperty("left", `${x}px`);
      this.mounted?.element.style.setProperty("top", `${y}px`);
    });
  }
}
