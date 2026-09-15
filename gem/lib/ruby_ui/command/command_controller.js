import { Controller } from "@hotwired/stimulus";
import Fuse from "fuse.js";

// Connects to data-controller="ruby-ui--command"
export default class extends Controller {
  static targets = ["input", "group", "item", "empty", "backdrop", "panel"];

  connect() {
    this.selectedIndex = -1;

    if (!this.hasInputTarget) {
      return;
    }

    this.inputTarget.focus();
    this.searchIndex = this.buildSearchIndex();
    this.toggleVisibility(this.emptyTargets, false);
  }

  disconnect() {
    // Torn down mid-open (Turbo nav/morph) never runs afterExit, the only place the
    // <body> scroll lock is released. Release it here for that path only; on a normal
    // close afterExit already handled it.
    if (this.hasPanelTarget && this.panelTarget.dataset.state !== "closed") {
      document.body.classList.remove("overflow-hidden");
    }
    // Nothing is left to wait for the exit animation, so apply the pending removal now.
    if (this.hasPanelTarget) this.settleExit(this.panelTarget);
  }

  dismiss() {
    this.backdropTarget.dataset.state = "closed";
    this.panelTarget.dataset.state = "closed";
    this.hideAfterExitAnimation(this.panelTarget);
  }

  // Opened again while dismissing: bring this instance back instead of stacking a new one.
  show() {
    this.backdropTarget.dataset.state = "open";
    this.panelTarget.dataset.state = "open";
    document.body.classList.add("overflow-hidden");
    this.focusInput();
  }

  afterExit() {
    document.body.classList.remove("overflow-hidden");
    this.element.remove();
  }

  // Overlay exit — the same block in every overlay controller, so keep them in sync.
  exitAnimationNames = new WeakMap();

  hideAfterExitAnimation(animated) {
    const exitAnimations = animated
      .getAnimations()
      .filter((animation) => animation instanceof CSSAnimation);

    // No exit animation, or no box to run it in: animationend would never fire.
    if (exitAnimations.length === 0) {
      this.settleExit(animated);
      return;
    }

    this.exitAnimationNames.set(animated, exitAnimations.map((animation) => animation.animationName));
    animated.addEventListener("animationend", this.handleExitAnimationEnd);
    animated.addEventListener("animationcancel", this.handleExitAnimationEnd);
  }

  handleExitAnimationEnd = (event) => {
    // animationend bubbles — an animated child must not hide its container.
    if (event.target !== event.currentTarget) return;
    // Closing mid-open cancels the enter animation; only the exit run settles this.
    if (!this.exitAnimationNames.get(event.currentTarget)?.includes(event.animationName)) return;

    this.settleExit(event.currentTarget);
  };

  settleExit(animated) {
    animated.removeEventListener("animationend", this.handleExitAnimationEnd);
    animated.removeEventListener("animationcancel", this.handleExitAnimationEnd);
    // Reopened mid-exit: it is on its way back in, leave it visible.
    if (animated.dataset.state !== "closed") return;

    this.afterExit(animated);
  }

  focusInput() {
    this.inputTarget?.focus();
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
