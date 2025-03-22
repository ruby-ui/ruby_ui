import { Controller } from "@hotwired/stimulus";

const LOCAL_STORAGE_KEY = "sidebar:open";
const TRIGGER_SELECTOR = "[data-sidebar='trigger']";
const State = {
  EXPANDED: "expanded",
  COLLAPSED: "collapsed",
};

export default class extends Controller {
  static values = {
    open: {
      type: Boolean,
      default: true,
    },
    collapsible: {
      type: String,
      default: "offcanvas",
    },
  };

  connect() {
    this.#setupTriggers();
  }

  disconnect() {
    this.#removeTriggers();
  }

  toggle() {
    this.openValue = !this.openValue;
  }

  openValueChanged() {
    this.#toggleSidebarDataState();
    this.#persistSidebarState();
  }

  #setupTriggers() {
    this.#triggerElements().forEach((trigger) => {
      trigger.addEventListener("click", this.toggle.bind(this));
    });
  }

  #removeTriggers() {
    this.#triggerElements().forEach((trigger) => {
      trigger.removeEventListener("click", this.toggle.bind(this));
    });
  }

  #triggerElements() {
    return document.querySelectorAll(TRIGGER_SELECTOR);
  }

  #toggleSidebarDataState() {
    this.element.dataset.state = this.openValue
      ? State.EXPANDED
      : State.COLLAPSED;
    this.element.dataset.collapsible = this.openValue
      ? ""
      : this.collapsibleValue;
  }

  #persistSidebarState() {
    localStorage.setItem(LOCAL_STORAGE_KEY, this.openValue);
  }
}
