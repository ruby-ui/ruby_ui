import { Controller } from "@hotwired/stimulus";

const SIDEBAR_COOKIE_NAME = "sidebar_state";
const SIDEBAR_COOKIE_MAX_AGE = 60 * 60 * 24 * 7;
const TRIGGER_SELECTOR = "[data-sidebar-trigger]";
const State = {
  EXPANDED: "expanded",
  COLLAPSED: "collapsed",
};
const MOBILE_BREAKPOINT = 768;

export default class extends Controller {
  static outlets = ["ruby-ui--sheet"];
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
    this.#setupSidebarTriggers();
  }

  disconnect() {
    this.#removeSidebarTriggers();
  }

  toggle() {
    if (this.#isMobile()) {
      this.#openMobileSidebar();

      return;
    }

    this.openValue = !this.openValue;
  }

  openValueChanged() {
    this.#updateSidebarState();
    this.#persistSidebarState();
  }

  #setupSidebarTriggers() {
    this.#siderbarTriggerElements().forEach((trigger) => {
      trigger.addEventListener("click", this.toggle.bind(this));
    });
  }

  #removeSidebarTriggers() {
    this.#siderbarTriggerElements().forEach((trigger) => {
      trigger.removeEventListener("click", this.toggle.bind(this));
    });
  }

  #siderbarTriggerElements() {
    return document.querySelectorAll(TRIGGER_SELECTOR);
  }

  #updateSidebarState() {
    const { dataset } = this.element;

    dataset.state = this.openValue ? State.EXPANDED : State.COLLAPSED;
    dataset.collapsible = this.openValue ? "" : this.collapsibleValue;
  }

  #persistSidebarState() {
    document.cookie = `${SIDEBAR_COOKIE_NAME}=${this.openValue}; path=/; max-age=${SIDEBAR_COOKIE_MAX_AGE}`;
  }

  #isMobile() {
    return window.innerWidth < MOBILE_BREAKPOINT;
  }

  #openMobileSidebar() {
    if (!this.rubyUiSheetOutlet) {
      return;
    }

    this.rubyUiSheetOutlet.open();
  }
}
