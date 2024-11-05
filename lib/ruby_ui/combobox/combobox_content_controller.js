import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item", "empty", "group"];

  handleSearchInput(value) {
    const query = this.#sanitizeStr(value);

    this.#toggleVisibility(this.itemTargets, false);

    const visibleItems = this.#filterItems(query);
    this.#toggleVisibility(visibleItems, true);

    this.#toggleVisibility(this.emptyTargets, visibleItems.length === 0);

    this.#updateGroupVisibility();
  }

  #updateGroupVisibility() {
    this.groupTargets.forEach((group) => {
      const hasVisibleItems = group.querySelectorAll("[data-rbui--combobox-content-target='item']:not(.hidden)").length > 0;
      this.#toggleVisibility([group], hasVisibleItems);
    });
  }

  #filterItems(query) {
    return this.itemTargets.filter((item) => this.#sanitizeStr(item.innerText).includes(query));
  }

  #toggleVisibility(elements, isVisible) {
    elements.forEach((el) => el.classList.toggle("hidden", !isVisible));
  }

  #sanitizeStr(str) {
    return str.toLowerCase().trim();
  }
}
