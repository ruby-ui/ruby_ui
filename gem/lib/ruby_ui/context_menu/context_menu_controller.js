import { Controller } from "@hotwired/stimulus";
import { computePosition, offset, flip, shift, size } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--context-menu"
//
// Behaves like Base UI's ContextMenu: the menu opens at the pointer, takes
// focus, and moves real focus between items (roving focus) on arrow keys,
// Home/End and typeahead. While open it is modal: the page scroll is locked
// and everything outside the menu is inert.
const ITEM_SELECTOR = "[role=menuitem], [role=menuitemcheckbox], [role=menuitemradio]";
const TYPEAHEAD_RESET_MS = 500;

export default class extends Controller {
  static targets = ["trigger", "content"];

  connect() {
    this.point = null;
    this.returnFocus = null;
    // The menu element while open: listeners and teardown use it even if the
    // content target has left the DOM (e.g. a Turbo Stream replaced it).
    this.openContent = null;
    this.inerted = [];
    this.addedScrollLock = false;
    this.typeahead = "";
    // A morph or a Turbo restore can bring back an open menu: settle on closed.
    if (this.hasContentTarget && (this.contentTarget.hasAttribute("data-open") || this.contentTarget.matches(":popover-open"))) {
      this.contentTarget.removeAttribute("data-open");
      this.settleExit(this.contentTarget);
    }
    document.addEventListener("turbo:before-cache", this.handleBeforeCache);
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache);
    this.close({ restoreFocus: false, animate: false });
  }

  // The open menu was removed on its own: release the page and the listeners.
  contentTargetDisconnected(content) {
    if (content === this.openContent) this.teardown();
  }

  get isOpen() {
    return this.openContent !== null;
  }

  // Only items that render: hidden ones (attribute, CSS or a hidden ancestor) are skipped.
  get items() {
    if (!this.openContent) return [];
    return [...this.openContent.querySelectorAll(ITEM_SELECTOR)].filter((item) => item.getClientRects().length > 0);
  }

  // --- Opening and closing ----------------------------------------------------

  handleContextMenu(event) {
    event.preventDefault();
    this.point = this.pointFrom(event, this.triggerTarget);
    this.isOpen ? this.position() : this.open();
  }

  // The ContextMenu key fires contextmenu without pointer coordinates.
  pointFrom(event, fallback) {
    if (event.clientX || event.clientY) return { x: event.clientX, y: event.clientY };
    const rect = fallback.getBoundingClientRect();
    return { x: rect.left, y: rect.top };
  }

  open() {
    if (!this.hasContentTarget || this.isOpen) return;
    const content = (this.openContent = this.contentTarget);
    const active = document.activeElement;
    this.returnFocus = active && active !== document.body ? active : null;

    // Set the origin before the enter animation starts; position() refines it.
    const align = content.dataset.align || "start";
    content.style.setProperty("--transform-origin", this.transformOrigin(content.dataset.preferredSide || "right", align));
    content.removeAttribute("data-closed");
    content.setAttribute("data-open", "");
    content.dataset.state = "open";
    if (!content.matches(":popover-open")) content.showPopover();
    this.position();
    this.makeModal();
    content.focus({ preventScroll: true });

    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.addEventListener("contextmenu", this.handleOutsideContextMenu, true);
    window.addEventListener("resize", this.handleResize);
  }

  close({ restoreFocus = true, animate = true } = {}) {
    const content = this.openContent;
    this.teardown();
    if (!content) return;

    const focusWasInside = content.contains(document.activeElement);
    content.removeAttribute("data-open");
    content.setAttribute("data-closed", "");
    content.dataset.state = "closed";
    animate ? this.hideAfterExitAnimation(content) : this.settleExit(content);

    if (focusWasInside) {
      // Leave the menu: back to what had focus before, or out of the popup.
      if (restoreFocus && this.returnFocus?.isConnected) this.returnFocus.focus({ preventScroll: true });
      else document.activeElement.blur();
    }
    this.returnFocus = null;
  }

  // Everything open() took from the page: listeners, inert, scroll lock.
  teardown() {
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.removeEventListener("contextmenu", this.handleOutsideContextMenu, true);
    window.removeEventListener("resize", this.handleResize);
    clearTimeout(this.typeaheadTimeout);
    this.typeahead = "";
    this.releaseModal();
    this.openContent = null;
  }

  // The viewport changed: keep the menu at the pointer and inside the screen.
  handleResize = () => {
    if (this.openContent) this.position();
  };

  handleOutsidePointerDown = (event) => {
    if (this.openContent?.contains(event.target)) return;
    // A right button press is handled by the contextmenu event that follows.
    if (event.button === 2) return;
    this.close({ restoreFocus: false });
  };

  // The page is inert while open, so a right click on the trigger lands on an
  // ancestor: tell it apart by position and move the menu there, as Base UI does.
  handleOutsideContextMenu = (event) => {
    if (this.openContent?.contains(event.target)) {
      event.preventDefault();
      return;
    }
    const rect = this.hasTriggerTarget ? this.triggerTarget.getBoundingClientRect() : null;
    const inTrigger =
      rect && event.clientX >= rect.left && event.clientX <= rect.right && event.clientY >= rect.top && event.clientY <= rect.bottom;
    if (inTrigger) {
      event.preventDefault();
      this.point = { x: event.clientX, y: event.clientY };
      this.position();
      this.openContent.focus({ preventScroll: true });
      return;
    }
    this.close({ restoreFocus: false });
  };

  // Turbo snapshots the page right after this event: never cache an open menu.
  handleBeforeCache = () => {
    this.close({ restoreFocus: false, animate: false });
  };

  // --- Modal: scroll lock + inert page ----------------------------------------

  makeModal() {
    // A lock someone else already holds stays theirs: only one this menu added is released.
    if (!document.body.classList.contains("overflow-hidden")) {
      document.body.classList.add("overflow-hidden");
      this.addedScrollLock = true;
    }
    // Everything but the menu's own branch of the tree, the trigger included.
    for (let node = this.openContent; node && node !== document.body; node = node.parentElement) {
      const parent = node.parentElement;
      if (!parent) break;
      for (const sibling of parent.children) {
        if (sibling === node || sibling.inert || sibling.tagName === "SCRIPT") continue;
        sibling.inert = true;
        this.inerted.push(sibling);
      }
    }
  }

  // Only undo what this menu did, and keep the lock while another modal is open.
  releaseModal() {
    this.inerted.forEach((element) => (element.inert = false));
    this.inerted = [];
    if (!this.addedScrollLock) return;
    this.addedScrollLock = false;
    const otherMenuOpen = [...document.querySelectorAll("[data-slot=context-menu-content][data-open]")].some(
      (menu) => menu !== this.openContent
    );
    if (!otherMenuOpen && !document.querySelector("dialog:modal")) document.body.classList.remove("overflow-hidden");
  }

  // --- Items ----------------------------------------------------------------

  activate(event) {
    const item = event.currentTarget;
    if (this.isDisabled(item)) {
      event.preventDefault();
      return;
    }

    const role = item.getAttribute("role");
    if (role === "menuitemcheckbox") {
      const checked = item.getAttribute("aria-checked") !== "true";
      item.setAttribute("aria-checked", String(checked));
      this.dispatch("change", { target: item, detail: { checked } });
    } else if (role === "menuitemradio") {
      const group = item.closest("[data-slot=context-menu-radio-group], [role=menu]");
      group.querySelectorAll("[role=menuitemradio]").forEach((radio) => radio.setAttribute("aria-checked", String(radio === item)));
      this.dispatch("change", { target: item, detail: { checked: true, value: item.dataset.value } });
    } else {
      // Plain items act and close; a link keeps its default navigation.
      this.close();
    }
  }

  hover(event) {
    const item = event.currentTarget;
    if (document.activeElement !== item && !this.isDisabled(item)) item.focus({ preventScroll: true });
  }

  // Leaving an item drops the highlight back to the menu itself.
  leave(event) {
    if (document.activeElement === event.currentTarget) this.openContent?.focus({ preventScroll: true });
  }

  // --- Keyboard -------------------------------------------------------------

  keydown(event) {
    if (!this.isOpen) return;
    const items = this.items;
    const current = items.indexOf(document.activeElement);

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.focusItem(items, current === -1 ? 0 : (current + 1) % items.length);
        break;
      case "ArrowUp":
        event.preventDefault();
        this.focusItem(items, current === -1 ? items.length - 1 : (current - 1 + items.length) % items.length);
        break;
      case "Home":
        event.preventDefault();
        this.focusItem(items, 0);
        break;
      case "End":
        event.preventDefault();
        this.focusItem(items, items.length - 1);
        break;
      case "Enter":
      case " ":
        event.preventDefault();
        if (current === -1) return;
        // Disabled items take focus (APG) but are never activated.
        if (!this.isDisabled(items[current])) items[current].click();
        break;
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.close();
        break;
      case "Tab":
        // Like Base UI's modal menu, focus stays in the menu (the page behind is inert).
        event.preventDefault();
        break;
      default:
        if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
          this.typeaheadTo(items, current, event.key);
        }
    }
  }

  focusItem(items, index) {
    items[index]?.focus({ preventScroll: false });
  }

  // Characters typed in quick succession build a prefix; a single repeated
  // character cycles through the items that start with it.
  typeaheadTo(items, current, key) {
    clearTimeout(this.typeaheadTimeout);
    this.typeaheadTimeout = setTimeout(() => (this.typeahead = ""), TYPEAHEAD_RESET_MS);
    this.typeahead += key.toLowerCase();

    const repeated = [...this.typeahead].every((char) => char === this.typeahead[0]);
    const prefix = repeated ? this.typeahead[0] : this.typeahead;
    const start = repeated || current === -1 ? current + 1 : current;
    const ordered = [...items.slice(start), ...items.slice(0, start)];
    const match = ordered.find((item) => this.labelOf(item).toLowerCase().startsWith(prefix));
    if (match) match.focus({ preventScroll: false });
  }

  // The item's own text, without its shortcut or indicator.
  labelOf(item) {
    return [...item.childNodes]
      .filter((node) => !(node.nodeType === Node.ELEMENT_NODE && node.matches("[data-slot$=-shortcut], [data-slot$=-indicator]")))
      .map((node) => node.textContent)
      .join("")
      .trim();
  }

  isDisabled(item) {
    return item.getAttribute("aria-disabled") === "true" || item.hasAttribute("data-disabled");
  }

  // --- Positioning ----------------------------------------------------------

  // A zero-size rect at the pointer stands in for the anchor.
  position() {
    const content = this.openContent;
    if (!content) return;
    const trigger = this.hasTriggerTarget ? this.triggerTarget : content;
    const { x, y } = this.point || this.pointFrom({}, trigger);
    const anchor = {
      getBoundingClientRect: () => ({ x, y, left: x, top: y, right: x, bottom: y, width: 0, height: 0 }),
      contextElement: trigger,
    };
    const side = content.dataset.preferredSide || "right";
    const align = content.dataset.align || "start";
    const placement = align === "center" ? side : `${side}-${align}`;
    const sideOffset = Number(content.dataset.sideOffset ?? 0);
    const alignOffset = Number(content.dataset.alignOffset ?? 4);

    computePosition(anchor, content, {
      strategy: "fixed",
      placement,
      middleware: [
        // alignmentAxis flips the offset for align: :end, as Base UI does.
        offset({ mainAxis: sideOffset, crossAxis: alignOffset, alignmentAxis: alignOffset }),
        flip(),
        shift({ padding: 5 }),
        size({
          padding: 5,
          apply({ availableHeight }) {
            content.style.setProperty("--available-height", `${availableHeight}px`);
          },
        }),
      ],
    }).then(({ x: left, y: top, placement: resolved }) => {
      if (!content.isConnected) return;
      const [resolvedSide, resolvedAlign] = resolved.split("-");
      Object.assign(content.style, { left: `${left}px`, top: `${top}px` });
      content.dataset.side = resolvedSide;
      content.style.setProperty("--transform-origin", this.transformOrigin(resolvedSide, resolvedAlign));
    });
  }

  // The menu grows out of the pointer.
  transformOrigin(side, align) {
    const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" }[side];
    const vertical = side === "top" || side === "bottom";
    const cross = { start: vertical ? "left" : "top", end: vertical ? "right" : "bottom" }[align] || "center";
    return vertical ? `${cross} ${opposite}` : `${opposite} ${cross}`;
  }

  // --- Exit animation (same block as the other overlay controllers) --------

  exitAnimationNames = new WeakMap();

  hideAfterExitAnimation(animated) {
    const exitAnimations = animated.getAnimations().filter((animation) => animation instanceof CSSAnimation);
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
    // Reopened mid-exit: it is on its way back in, leave it showing.
    if (animated.hasAttribute("data-open")) return;
    animated.removeAttribute("data-open");
    animated.setAttribute("data-closed", "");
    animated.dataset.state = "closed";
    if (animated.matches(":popover-open")) animated.hidePopover();
  }
}
