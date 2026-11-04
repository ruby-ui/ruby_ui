import { Controller } from "@hotwired/stimulus";

const SIDEBAR_COOKIE_NAME = "sidebar_state";
const SIDEBAR_COOKIE_MAX_AGE = 60 * 60 * 24 * 7;
const State = {
  EXPANDED: "expanded",
  COLLAPSED: "collapsed",
};
const MOBILE_BREAKPOINT = 768;

export default class extends Controller {
  static targets = ["sidebar", "mobileSidebar"];

  sidebarTargetConnected() {
    const { state, collapsibleKind } = this.sidebarTarget.dataset;

    this.open = state === State.EXPANDED;
    this.collapsibleKind = collapsibleKind;
  }

  toggle(e) {
    // A non-collapsible sidebar has neither target: leave the event (e.g.
    // Ctrl+B in an editor) and the sidebar_state cookie alone.
    if (this.#isMobile()) {
      if (!this.hasMobileSidebarTarget) return;

      e.preventDefault();
      this.#openMobileSidebar();

      return;
    }

    if (!this.hasSidebarTarget) return;

    e.preventDefault();
    this.open = !this.open;
    this.onToggle();
  }

  onToggle() {
    this.#updateSidebarState();
    this.#persistSidebarState();
    // shadcn's onOpenChange: listen with
    // data-action="ruby-ui--sidebar:change->your-controller#method".
    this.dispatch("change", { detail: { open: this.open } });
  }

  #updateSidebarState() {
    if (!this.hasSidebarTarget) {
      return;
    }

    const { dataset } = this.sidebarTarget;

    dataset.state = this.open ? State.EXPANDED : State.COLLAPSED;
    dataset.collapsible = this.open ? "" : this.collapsibleKind;
  }

  #persistSidebarState() {
    document.cookie = `${SIDEBAR_COOKIE_NAME}=${this.open}; path=/; max-age=${SIDEBAR_COOKIE_MAX_AGE}`;
  }

  #isMobile() {
    return window.innerWidth < MOBILE_BREAKPOINT;
  }

  #openMobileSidebar() {
    if (!this.hasMobileSidebarTarget) {
      return;
    }

    this.mobileSidebarTarget.dispatchEvent(
      new CustomEvent("ruby--ui-sidebar:open"),
    );
  }
}
