import { Controller } from "@hotwired/stimulus";
import Fuse from "fuse.js";

// Connects to data-controller="ruby-ui--command"
export default class extends Controller {
  static targets = ["input", "group", "item", "empty", "content"];

  static values = {
    open: {
      type: Boolean,
      default: false,
    },
  };

  connect() {
    this.inputTarget.focus();
    this.searchIndex = this.buildSearchIndex();
    this.toggleVisibility(this.emptyTargets, false);
    this.selectedIndex = -1;

    if (this.openValue) {
      this.open();
    }
  }

  open(e) {
    e.preventDefault();
    document.body.insertAdjacentHTML("beforeend", this.contentTarget.innerHTML);
    // prevent scroll on body
    document.body.classList.add("overflow-hidden");
  }

  dismiss() {
    // allow scroll on body
    document.body.classList.remove("overflow-hidden");
    // remove the element
    this.element.remove();
  }

  filter(e) {
    // Deselect any previously selected item
    this.deselectAll();

    const query = e.target.value.toLowerCase();
    if (query.length === 0) {
      this.resetVisibility();
      return;
    }

    this.toggleVisibility(this.itemTargets, false);

    const results = this.searchIndex.search(query);
    results.forEach((result) =>
      this.toggleVisibility([result.item.element], true),
    );

    this.toggleVisibility(this.emptyTargets, results.length === 0);
    this.updateGroupVisibility();
  }

  toggleVisibility(elements, isVisible) {
    elements.forEach((el) => el.classList.toggle("hidden", !isVisible));
  }

  updateGroupVisibility() {
    this.groupTargets.forEach((group) => {
      const hasVisibleItems =
        group.querySelectorAll(
          "[data-ruby-ui--command-target='item']:not(.hidden)",
        ).length > 0;
      this.toggleVisibility([group], hasVisibleItems);
    });
  }

  resetVisibility() {
    this.toggleVisibility(this.itemTargets, true);
    this.toggleVisibility(this.groupTargets, true);
    this.toggleVisibility(this.emptyTargets, false);
  }

  buildSearchIndex() {
    const options = {
      keys: ["value"],
      threshold: 0.2,
      includeMatches: true,
    };
    const items = this.itemTargets.map((el) => ({
      value: el.dataset.value,
      element: el,
    }));
    return new Fuse(items, options);
  }

  handleKeydown(e) {
    const visibleItems = this.itemTargets.filter(
      (item) => !item.classList.contains("hidden"),
    );
    if (e.key === "ArrowDown") {
      e.preventDefault();
      this.updateSelectedItem(visibleItems, 1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this.updateSelectedItem(visibleItems, -1);
    } else if (e.key === "Enter" && this.selectedIndex !== -1) {
      e.preventDefault();
      visibleItems[this.selectedIndex].click();
    }
  }

  updateSelectedItem(visibleItems, direction) {
    if (this.selectedIndex >= 0) {
      this.toggleAriaSelected(visibleItems[this.selectedIndex], false);
    }

    this.selectedIndex += direction;

    // Ensure the selected index is within the bounds of the visible items
    if (this.selectedIndex < 0) {
      this.selectedIndex = visibleItems.length - 1;
    } else if (this.selectedIndex >= visibleItems.length) {
      this.selectedIndex = 0;
    }

    this.toggleAriaSelected(visibleItems[this.selectedIndex], true);
  }

  toggleAriaSelected(element, isSelected) {
    element.setAttribute("aria-selected", isSelected.toString());
  }

  deselectAll() {
    this.itemTargets.forEach((item) => this.toggleAriaSelected(item, false));
    this.selectedIndex = -1;
  }
}
