import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--tabs"
//
// Follows Base UI's Tabs: role=tablist/tab/tabpanel, each tab pointing at its
// panel (aria-controls) and each panel labelled by its tab, a roving tabindex
// on the tabs, arrow keys that move focus (wrapping unless the list says
// data-loop-focus="false"), Home/End, and manual activation by Enter, Space or
// click (or on focus with data-activate-on-focus="true"). Disabled tabs
// (aria-disabled) stay reachable but never activate.
export default class extends Controller {
  static targets = ["list", "trigger", "content"];
  static values = { active: String, orientation: { type: String, default: "horizontal" } };

  connect() {
    this.idBase = this.element.id || `ruby-ui-tabs-${Math.random().toString(36).slice(2, 10)}`;
    this.connected = true;
    this.refresh();
  }

  disconnect() {
    this.connected = false;
  }

  activeValueChanged() {
    if (this.connected) this.sync();
  }

  orientationValueChanged() {
    if (this.connected) this.sync();
  }

  // Tabs and panels added later (a morph, lazy content) get wired too.
  triggerTargetConnected() {
    if (this.connected) this.refresh();
  }

  contentTargetConnected() {
    if (this.connected) this.refresh();
  }

  refresh() {
    this.wire();
    if (!this.triggerFor(this.activeValue)) {
      const first = this.triggerTargets.find((tab) => !this.isDisabled(tab)) ?? this.triggerTargets[0];
      // Assigning the value runs sync through activeValueChanged.
      if (first && first.dataset.value !== this.activeValue) {
        this.activeValue = first.dataset.value;
        return;
      }
    }
    this.sync();
  }

  // --- Activation --------------------------------------------------------------

  show(event) {
    const tab = event.currentTarget;
    if (this.isDisabled(tab)) {
      event.preventDefault();
      return;
    }
    this.activate(tab);
  }

  activate(tab) {
    const value = tab.dataset.value;
    if (value === this.activeValue) return;
    const previousValue = this.activeValue;
    this.activeValue = value;
    this.dispatch("change", { detail: { value, previousValue } });
  }

  // --- Keyboard ----------------------------------------------------------------

  keydown(event) {
    const tab = event.target.closest('[role="tab"]');
    if (!tab || !this.triggerTargets.includes(tab)) return;

    // A link tab activates on Enter by itself; Space needs a click.
    if (event.key === " " && tab.tagName === "A") {
      event.preventDefault();
      tab.click();
      return;
    }

    const tabs = this.triggerTargets;
    const index = tabs.indexOf(tab);
    const last = tabs.length - 1;
    const [previousKey, nextKey] = this.navigationKeys();
    let target;

    if (event.key === nextKey) target = index === last ? (this.loopFocus ? 0 : last) : index + 1;
    else if (event.key === previousKey) target = index === 0 ? (this.loopFocus ? last : 0) : index - 1;
    else if (event.key === "Home") target = 0;
    else if (event.key === "End") target = last;
    else return;

    event.preventDefault();
    this.focusTab(tabs[target]);
  }

  navigationKeys() {
    if (this.orientationValue === "vertical") return ["ArrowUp", "ArrowDown"];
    const rtl = getComputedStyle(this.hasListTarget ? this.listTarget : this.element).direction === "rtl";
    return rtl ? ["ArrowRight", "ArrowLeft"] : ["ArrowLeft", "ArrowRight"];
  }

  focusTab(tab) {
    this.triggerTargets.forEach((el) => el.setAttribute("tabindex", el === tab ? "0" : "-1"));
    tab.focus();
    if (this.activateOnFocus && !this.isDisabled(tab)) this.activate(tab);
  }

  get loopFocus() {
    return !this.hasListTarget || this.listTarget.dataset.loopFocus !== "false";
  }

  get activateOnFocus() {
    return this.hasListTarget && this.listTarget.dataset.activateOnFocus === "true";
  }

  // --- State -------------------------------------------------------------------

  wire() {
    this.triggerTargets.forEach((tab) => {
      if (!tab.id) tab.id = this.idFor("tab", tab.dataset.value);
    });
    this.contentTargets.forEach((panel) => {
      if (!panel.id) panel.id = this.idFor("panel", panel.dataset.value);
      const tab = this.triggerFor(panel.dataset.value);
      if (tab) {
        tab.setAttribute("aria-controls", panel.id);
        panel.setAttribute("aria-labelledby", tab.id);
      }
    });
  }

  sync() {
    const orientation = this.orientationValue;
    const active = this.triggerFor(this.activeValue);

    if (this.hasListTarget) {
      this.listTarget.dataset.orientation = orientation;
      if (orientation === "vertical") this.listTarget.setAttribute("aria-orientation", "vertical");
      else this.listTarget.removeAttribute("aria-orientation");
    }

    this.triggerTargets.forEach((tab, index) => {
      const selected = tab === active;
      tab.dataset.orientation = orientation;
      tab.setAttribute("aria-selected", String(selected));
      tab.toggleAttribute("data-active", selected);
      tab.setAttribute("tabindex", selected || (!active && index === 0) ? "0" : "-1");
    });

    this.contentTargets.forEach((panel) => {
      panel.dataset.orientation = orientation;
      panel.hidden = panel.dataset.value !== this.activeValue || !active;
    });
  }

  triggerFor(value) {
    if (value === undefined || value === null || value === "") return undefined;
    return this.triggerTargets.find((tab) => tab.dataset.value === value);
  }

  isDisabled(tab) {
    return tab.disabled || tab.getAttribute("aria-disabled") === "true";
  }

  idFor(kind, value) {
    return `${this.idBase}-${kind}-${String(value).replace(/[^\w-]/g, "-")}`;
  }
}
