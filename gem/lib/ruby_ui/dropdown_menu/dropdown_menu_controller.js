import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, flip, shift, size } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--dropdown-menu"
//
// Behaves like Base UI's Menu (shadcn's DropdownMenu): a button opens the
// menu next to itself, focus moves into it (roving focus) and between items on
// arrow keys, Home/End and typeahead; Esc, Tab, picking an item or a click
// outside close it and focus goes back to the button. The menu and its
// submenus are native popovers (top layer). While open it is modal by
// default: the page scroll is locked and everything outside is inert.
const ITEM_SELECTOR = "[role=menuitem], [role=menuitemcheckbox], [role=menuitemradio]";
const CONTROL_SELECTOR = "button, a[href], [role=button]";
const OPEN_MENU_SELECTOR = "[data-slot=dropdown-menu-content][data-open], [data-slot=context-menu-content][data-open]";
// Elements whose Enter/Space already fire a click.
const NATIVE_CLICK_SELECTOR = "button, a[href], input, summary";
// Controls inside custom menu content that handle their own keys.
const FORM_CONTROL_SELECTOR = "input, textarea, select, button, a[href], [contenteditable]:not([contenteditable=false]), [role=textbox], [role=combobox]";
const TYPEAHEAD_RESET_MS = 500;
let uid = 0;

export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = {
    open: { type: Boolean, default: false },
    modal: { type: Boolean, default: true },
    // Legacy: {placement: "bottom-start"} stands in for side:/align: on the content.
    options: { type: Object, default: {} },
  };

  initialize() {
    this.openContent = null;
    this.returnFocus = null;
    this.inerted = [];
    this.addedScrollLock = false;
    this.typeahead = "";
    this.positionCleanups = new Map();
    this.controls = new Map();
    this.exitAnimationNames = new WeakMap();
  }

  connect() {
    this.element.addEventListener("keydown", this.handleTriggerKeydown);
    this.element.addEventListener("focusin", this.handleFocusIn);
    this.element.addEventListener("focusout", this.handleFocusOut);
    // A morph or a Turbo restore can bring back an open menu: settle on closed.
    this.element.querySelectorAll("[data-slot$=content][data-open]").forEach((menu) => {
      menu.removeAttribute("data-open");
      this.settleExit(menu);
    });
    document.addEventListener("turbo:before-cache", this.handleBeforeCache);
    this.connected = true;
    if (this.openValue) this.open({ focus: null });
  }

  disconnect() {
    this.connected = false;
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache);
    document.removeEventListener("mousedown", this.preventFocusSteal, { capture: true });
    this.element.removeEventListener("keydown", this.handleTriggerKeydown);
    this.element.removeEventListener("focusin", this.handleFocusIn);
    this.element.removeEventListener("focusout", this.handleFocusOut);
    this.close({ restoreFocus: false, animate: false });
  }

  // data-highlighted marks the item with focus, as Base UI does (styles can target either).
  handleFocusIn = (event) => {
    if (event.target.matches?.(ITEM_SELECTOR)) event.target.setAttribute("data-highlighted", "");
  };

  handleFocusOut = (event) => {
    if (event.target.matches?.(ITEM_SELECTOR)) event.target.removeAttribute("data-highlighted");
  };

  openValueChanged(open) {
    if (!this.connected) return;
    if (open && !this.isOpen) this.open({ focus: null });
    if (!open && this.isOpen) this.close();
  }

  // --- Trigger ----------------------------------------------------------------

  triggerTargetConnected(trigger) {
    this.setupControl(trigger);
  }

  triggerTargetDisconnected(trigger) {
    this.controls.delete(trigger);
  }

  // Gives the trigger's control its ARIA and slot, matching the current state.
  setupControl(trigger) {
    const control = this.controlFor(trigger);
    this.controls.set(trigger, control);
    control.id ||= `dropdown-menu-trigger-${++uid}`;
    control.setAttribute("aria-haspopup", "menu");
    control.setAttribute("aria-expanded", String(this.isOpen));
    if (this.isOpen) {
      control.setAttribute("aria-controls", this.openContent.id);
      control.setAttribute("data-popup-open", "");
    }
    // Keep a slot the element already has for its own styling (e.g. a sidebar action).
    if (!control.dataset.slot || control.dataset.slot === "button") control.dataset.slot = "dropdown-menu-trigger";
    return control;
  }

  // The element that carries the trigger's role: the target itself when it is
  // a button, the button inside the wrapper otherwise. A wrapper with nothing
  // focusable inside becomes the button.
  controlFor(trigger) {
    if (trigger.matches(CONTROL_SELECTOR)) return trigger;
    const inner = trigger.querySelector(CONTROL_SELECTOR);
    if (inner) return inner;
    trigger.classList.remove("contents");
    trigger.classList.add("inline-block");
    trigger.setAttribute("role", "button");
    if (!trigger.hasAttribute("tabindex")) trigger.tabIndex = 0;
    return trigger;
  }

  // Resolved again when a morph swapped the button inside the wrapper.
  get control() {
    if (!this.hasTriggerTarget) return null;
    const trigger = this.triggerTarget;
    const control = this.controls.get(trigger);
    if (control?.isConnected && (control === trigger || trigger.contains(control))) return control;
    return this.setupControl(trigger);
  }

  // A real click focuses the menu; Enter/Space (a click with detail 0) focus the first item.
  toggle(event) {
    if (this.isOpen) {
      this.close();
    } else {
      this.open({ focus: event?.detail === 0 ? "first" : "menu" });
    }
  }

  // Delegated from the root, so a button swapped by a morph keeps working.
  handleTriggerKeydown = (event) => {
    const control = this.control;
    if (!control || event.target !== control) return;
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      const focus = event.key === "ArrowDown" ? "first" : "last";
      if (this.isOpen) this.focusEdge(this.openContent, focus);
      else this.open({ focus });
    } else if ((event.key === "Enter" || event.key === " ") && !control.matches(NATIVE_CLICK_SELECTOR)) {
      // A non-native button (e.g. a wrapper with only text) gets no click from these keys.
      event.preventDefault();
      if (this.isOpen) this.close();
      else this.open({ focus: "first" });
    }
  };

  // --- Opening and closing ----------------------------------------------------

  get isOpen() {
    return this.openContent !== null;
  }

  open({ focus = "menu" } = {}) {
    if (!this.hasContentTarget || this.isOpen) return;
    const content = (this.openContent = this.contentTarget);
    const control = this.control;
    content.id ||= `dropdown-menu-content-${++uid}`;
    if (control) {
      control.setAttribute("aria-expanded", "true");
      control.setAttribute("aria-controls", content.id);
      control.setAttribute("data-popup-open", "");
      content.setAttribute("aria-labelledby", control.id);
    }
    this.returnFocus = control;

    this.show(content, control || this.element, { ...this.placementOf(content), matchWidth: true });
    if (this.modalValue) this.makeModal();
    if (focus === "first" || focus === "last") this.focusEdge(content, focus);
    else if (focus === "menu") content.focus({ preventScroll: true });

    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);
    this.openValue = true;
    this.dispatch("open-change", { detail: { open: true } });
  }

  close({ restoreFocus = true, animate = true } = {}) {
    const content = this.openContent;
    if (!content) return;
    const focusWasInside = content.contains(document.activeElement);
    this.openSubTriggersIn(content).forEach((trigger) => this.closeSub(trigger, { animate }));
    this.teardown();
    this.hide(content, { animate });

    this.resetControl(content);
    // Leave the menu for the button, unless something else took focus on
    // purpose (an item that opened a modal dialog, a click outside).
    const focusLeft = focusWasInside || document.activeElement === document.body;
    // Only a dialog opened from inside this menu; a dialog that contains the menu doesn't count.
    const dialogTookFocus = [...document.querySelectorAll("dialog:modal")].some((dialog) => content.contains(dialog));
    if (dialogTookFocus) {
      // Leave focus where the dialog put it.
    } else if (restoreFocus && focusLeft && this.returnFocus?.isConnected) {
      this.returnFocus.focus({ preventScroll: true });
    } else if (focusWasInside && content.contains(document.activeElement)) {
      document.activeElement.blur();
    }
    this.returnFocus = null;
    this.openValue = false;
    this.dispatch("open-change", { detail: { open: false } });
  }

  // Everything open() took from the page: listeners, inert, scroll lock.
  teardown() {
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    // Every autoUpdate still running (menu and submenus), even for elements that left the DOM.
    this.positionCleanups.forEach((cleanup) => cleanup());
    this.positionCleanups.clear();
    clearTimeout(this.typeaheadTimeout);
    this.typeahead = "";
    this.releaseModal();
    this.openContent = null;
  }

  resetControl(content) {
    const control = this.control;
    if (!control) return;
    control.setAttribute("aria-expanded", "false");
    control.removeAttribute("data-popup-open");
    if (control.getAttribute("aria-controls") === content.id) control.removeAttribute("aria-controls");
  }

  // The open menu was removed on its own (e.g. a Turbo Stream replaced it):
  // release the page and the listeners, and tell the button it is closed.
  contentTargetDisconnected(content) {
    if (content !== this.openContent) return;
    this.teardown();
    this.resetControl(content);
    this.returnFocus = null;
    this.openValue = false;
    this.dispatch("open-change", { detail: { open: false } });
  }

  handleOutsidePointerDown = (event) => {
    if (this.openContent?.contains(event.target)) return;
    // The button toggles on its own click.
    if (this.control?.contains(event.target)) return;
    // Modal: the page is inert, so the press must not move focus to the body
    // after it went back to the button.
    // The mousedown comes in the same burst as this pointerdown; the next task
    // drops the guard if it never came (pen, touch without compat events).
    if (this.modalValue) {
      document.addEventListener("mousedown", this.preventFocusSteal, { capture: true, once: true });
      setTimeout(() => document.removeEventListener("mousedown", this.preventFocusSteal, { capture: true }));
    }
    this.close();
  };

  preventFocusSteal = (event) => event.preventDefault();

  // Turbo snapshots the page right after this event: never cache an open menu.
  handleBeforeCache = () => {
    this.close({ restoreFocus: false, animate: false });
  };

  show(menu, anchor, placement) {
    menu.style.setProperty("--transform-origin", this.transformOrigin(placement.side, placement.align));
    menu.dataset.side = placement.side;
    menu.removeAttribute("data-closed");
    menu.setAttribute("data-open", "");
    menu.dataset.state = "open";
    if (!menu.matches(":popover-open")) menu.showPopover();
    this.stopPositioning(menu);
    this.positionCleanups.set(
      menu,
      autoUpdate(anchor, menu, () => this.position(menu, anchor, placement))
    );
  }

  hide(menu, { animate }) {
    this.stopPositioning(menu);
    menu.removeAttribute("data-open");
    menu.setAttribute("data-closed", "");
    menu.dataset.state = "closed";
    animate ? this.hideAfterExitAnimation(menu) : this.settleExit(menu);
  }

  stopPositioning(menu) {
    this.positionCleanups.get(menu)?.();
    this.positionCleanups.delete(menu);
  }

  // --- Modal: scroll lock + inert page ----------------------------------------

  makeModal() {
    // A lock someone else already holds stays theirs: only one this menu added is released.
    if (!document.body.classList.contains("overflow-hidden")) {
      document.body.classList.add("overflow-hidden");
      this.addedScrollLock = true;
    }
    // Everything but the menu's own branch of the tree (trigger and menu).
    for (let node = this.element; node && node !== document.body; node = node.parentElement) {
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
    const otherMenuOpen = [...document.querySelectorAll(OPEN_MENU_SELECTOR)].some((menu) => menu !== this.openContent);
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
      const group = item.closest("[data-slot=dropdown-menu-radio-group], [role=menu]");
      group.querySelectorAll("[role=menuitemradio]").forEach((radio) => radio.setAttribute("aria-checked", String(radio === item)));
      this.dispatch("change", { target: item, detail: { checked: true, value: item.dataset.value } });
    } else {
      // Plain items act and close; a link keeps its default navigation.
      this.close();
    }
  }

  hover(event) {
    const item = event.currentTarget;
    if (this.isDisabled(item)) return;
    // Pointing at another item of a menu closes the submenu open from it.
    const menu = item.closest("[role=menu]");
    this.openSubTriggersIn(menu, { direct: true })
      .filter((trigger) => trigger !== item)
      .forEach((trigger) => this.closeSub(trigger));
    if (this.isSubTrigger(item)) this.openSub(item, { focus: false });
    if (document.activeElement !== item) item.focus({ preventScroll: true });
  }

  // Leaving an item drops the highlight back to its menu.
  leave(event) {
    const item = event.currentTarget;
    if (document.activeElement === item) item.closest("[role=menu]")?.focus({ preventScroll: true });
  }

  // --- Submenus -------------------------------------------------------------

  isSubTrigger(item) {
    return item.dataset.slot === "dropdown-menu-sub-trigger";
  }

  // Looked up inside the root, so it is found even after the root left the DOM.
  subOf(trigger) {
    const id = trigger.getAttribute("aria-controls");
    return id ? this.element.querySelector(`#${CSS.escape(id)}`) : null;
  }

  triggerOfSub(sub) {
    return this.element.querySelector(`[data-slot=dropdown-menu-sub-trigger][aria-controls="${sub.id}"]`);
  }

  // Sub triggers with an open submenu inside a menu; direct: only its own items.
  openSubTriggersIn(menu, { direct = false } = {}) {
    if (!menu) return [];
    return [...menu.querySelectorAll("[data-slot=dropdown-menu-sub-trigger][aria-expanded=true]")].filter(
      (trigger) => !direct || trigger.closest("[role=menu]") === menu
    );
  }

  // A click opens the submenu (pointer: focus stays; keyboard: first item).
  toggleSub(event) {
    const trigger = event.currentTarget;
    if (this.isDisabled(trigger)) return;
    this.openSub(trigger, { focus: event.detail === 0 });
  }

  openSub(trigger, { focus }) {
    const sub = this.subOf(trigger);
    if (!sub) return;
    if (trigger.getAttribute("aria-expanded") !== "true") {
      trigger.setAttribute("aria-expanded", "true");
      trigger.setAttribute("data-popup-open", "");
      this.show(sub, trigger, {
        side: sub.dataset.preferredSide || "right",
        align: sub.dataset.align || "start",
        sideOffset: Number(sub.dataset.sideOffset ?? 0),
        alignOffset: Number(sub.dataset.alignOffset ?? -3),
      });
    }
    if (focus) this.focusEdge(sub, "first");
  }

  closeSub(trigger, { animate = true, focusTrigger = false } = {}) {
    const sub = this.subOf(trigger);
    trigger.setAttribute("aria-expanded", "false");
    trigger.removeAttribute("data-popup-open");
    if (sub) {
      this.openSubTriggersIn(sub).forEach((nested) => this.closeSub(nested, { animate }));
      if (sub.hasAttribute("data-open")) this.hide(sub, { animate });
    }
    if (focusTrigger) trigger.focus({ preventScroll: true });
  }

  // --- Keyboard -------------------------------------------------------------

  // Keys reach the root menu from its submenus too (they live inside it).
  keydown(event) {
    if (!this.isOpen) return;
    const target = event.target;
    // A form control in custom content (an input, a checkbox) keeps its own
    // keys; only Esc still closes the menu from there.
    if (!target.matches(ITEM_SELECTOR) && target.matches(FORM_CONTROL_SELECTOR) && event.key !== "Escape") return;
    const menu = target.closest("[role=menu]") || this.openContent;
    const items = this.itemsOf(menu);
    const current = items.indexOf(document.activeElement);
    const item = items[current];

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
      case "ArrowRight":
        if (item && this.isSubTrigger(item) && !this.isDisabled(item)) {
          event.preventDefault();
          this.openSub(item, { focus: true });
        }
        break;
      case "ArrowLeft":
        if (menu !== this.openContent) {
          event.preventDefault();
          const trigger = this.triggerOfSub(menu);
          if (trigger) this.closeSub(trigger, { focusTrigger: true });
        }
        break;
      case "Enter":
      case " ":
        event.preventDefault();
        if (!item || this.isDisabled(item)) return;
        // Disabled items take focus (APG) but are never activated.
        if (this.isSubTrigger(item)) this.openSub(item, { focus: true });
        // An item hosting its own control (e.g. a DialogTrigger) passes the key on to it.
        else (item.querySelector(CONTROL_SELECTOR + ", [data-action*='click->']") || item).click();
        break;
      case "Escape": {
        event.preventDefault();
        event.stopPropagation();
        const trigger = menu !== this.openContent && this.triggerOfSub(menu);
        if (trigger) this.closeSub(trigger, { focusTrigger: true });
        else this.close();
        break;
      }
      case "Tab":
        // Like Base UI's menu, Tab closes it and focus goes back to the button.
        event.preventDefault();
        this.close();
        break;
      default:
        if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
          this.typeaheadTo(items, current, event.key);
        }
    }
  }

  // Only a menu's own items that render: a submenu's items and hidden ones are skipped.
  itemsOf(menu) {
    if (!menu) return [];
    return [...menu.querySelectorAll(ITEM_SELECTOR)].filter(
      (item) => item.closest("[role=menu]") === menu && item.getClientRects().length > 0
    );
  }

  focusEdge(menu, edge) {
    const items = this.itemsOf(menu);
    // A menu with no items (only custom content) takes focus itself.
    const target = items.length ? (edge === "last" ? items[items.length - 1] : items[0]) : menu;
    target.focus({ preventScroll: true });
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
      .filter((node) => !(node.nodeType === Node.ELEMENT_NODE && node.matches("[data-slot$=-shortcut], [data-slot$=-indicator], svg")))
      .map((node) => node.textContent)
      .join("")
      .trim();
  }

  isDisabled(item) {
    return item.getAttribute("aria-disabled") === "true" || item.hasAttribute("data-disabled");
  }

  // --- Positioning ----------------------------------------------------------

  // side:/align: on the content win; the legacy options[:placement] fills in.
  placementOf(content) {
    const [legacySide, legacyAlign] = (this.optionsValue.placement || "").split("-");
    const side = content.dataset.preferredSide || legacySide || "bottom";
    const align = content.dataset.align || (legacySide ? legacyAlign || "center" : "start");
    return {
      side,
      align,
      sideOffset: Number(content.dataset.sideOffset ?? 4),
      alignOffset: Number(content.dataset.alignOffset ?? 0),
    };
  }

  position(menu, anchor, { side, align, sideOffset = 4, alignOffset = 0, matchWidth = false }) {
    const placement = align === "center" ? side : `${side}-${align}`;
    computePosition(anchor, menu, {
      strategy: "fixed",
      placement,
      middleware: [
        // alignmentAxis flips the offset for align: :end, as Base UI does.
        offset({ mainAxis: sideOffset, alignmentAxis: alignOffset }),
        flip(),
        shift({ padding: 5 }),
        size({
          padding: 5,
          apply({ availableHeight, rects }) {
            menu.style.setProperty("--available-height", `${availableHeight}px`);
            if (matchWidth) menu.style.setProperty("--anchor-width", `${rects.reference.width}px`);
          },
        }),
      ],
    }).then(({ x, y, placement: resolved }) => {
      if (!menu.isConnected || !menu.hasAttribute("data-open")) return;
      const [resolvedSide, resolvedAlign = "center"] = resolved.split("-");
      Object.assign(menu.style, { left: `${x}px`, top: `${y}px` });
      menu.dataset.side = resolvedSide;
      menu.style.setProperty("--transform-origin", this.transformOrigin(resolvedSide, resolvedAlign));
    });
  }

  // The menu grows out of the trigger's edge.
  transformOrigin(side, align) {
    const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" }[side];
    const vertical = side === "top" || side === "bottom";
    const cross = { start: vertical ? "left" : "top", end: vertical ? "right" : "bottom" }[align] || "center";
    return vertical ? `${cross} ${opposite}` : `${opposite} ${cross}`;
  }

  // --- Exit animation (same block as the other overlay controllers) --------

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
    animated.setAttribute("data-closed", "");
    animated.dataset.state = "closed";
    // An item opened a modal dialog that lives inside the menu: hiding the
    // popover would hide the dialog too. The exit animation already left the
    // menu transparent; hide it once the dialog closes.
    const dialog = animated.querySelector("dialog[open]");
    if (dialog) {
      dialog.addEventListener("close", () => this.settleAfterDialog(animated), { once: true });
      return;
    }
    if (animated.matches(":popover-open")) animated.hidePopover();
  }

  settleAfterDialog(menu) {
    if (menu.hasAttribute("data-open")) return;
    const focusWasInside = menu.contains(document.activeElement) || document.activeElement === document.body;
    if (menu.matches(":popover-open")) menu.hidePopover();
    // The dialog returned focus to its trigger inside the menu: move it to the menu's button.
    if (focusWasInside && menu === this.contentTarget) this.control?.focus({ preventScroll: true });
  }
}
