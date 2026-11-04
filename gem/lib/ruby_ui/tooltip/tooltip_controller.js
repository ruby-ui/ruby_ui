import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, flip, shift, arrow } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--tooltip"
//
// Behaves like Base UI's Tooltip: it opens while the pointer rests on the
// trigger (after delay) or when the trigger gets keyboard focus, and closes
// when the pointer leaves both the trigger and the content, on blur, on
// Escape, or when the trigger is pressed (close_on_click). The pointer can
// move onto the content without closing it (WCAG 1.4.13).
//
// TooltipContent ships in a <template>. On connect the controller places a
// copy right after the trigger, so it stays inside the same container (a
// Sidebar hides its tooltips from its own data-state), and opens it as a
// native popover="manual" in the top layer; Floating UI places it next to
// the trigger. The content has role="tooltip" and the trigger's focusable
// element points at it with aria-describedby, as the APG tooltip pattern
// asks (Base UI leaves both out).
const SIDES = ["top", "right", "bottom", "left", "inline-start", "inline-end"];
const ALIGNS = ["start", "center", "end"];
const FOCUSABLE = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
// The pointer needs a moment to cross the gap between trigger and content.
const HOVER_GRACE = 100;

export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = {
    placement: { type: String, default: "top" },
    open: { type: Boolean, default: false },
    disabled: { type: Boolean, default: false },
  };

  // The copy of the content template that lives in the page.
  popup = null;
  isOpen = false;

  connect() {
    document.addEventListener("turbo:before-cache", this.handleBeforeCache);
    this.mount();
    if (this.openValue && !this.disabledValue) this.open();
    this.ready = true;
  }

  disconnect() {
    this.ready = false;
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache);
    this.unmount();
  }

  // Target callbacks run before connect() and again whenever Turbo or other
  // code swaps the trigger or the content inside a connected tooltip.
  triggerTargetConnected(trigger) {
    trigger.addEventListener("mouseenter", this.handleEnter);
    trigger.addEventListener("mouseleave", this.handleLeave);
    trigger.addEventListener("focusin", this.handleFocusIn);
    trigger.addEventListener("focusout", this.handleFocusOut);
    trigger.addEventListener("click", this.handleClick);
    if (this.ready) this.remount();
  }

  triggerTargetDisconnected(trigger) {
    trigger.removeEventListener("mouseenter", this.handleEnter);
    trigger.removeEventListener("mouseleave", this.handleLeave);
    trigger.removeEventListener("focusin", this.handleFocusIn);
    trigger.removeEventListener("focusout", this.handleFocusOut);
    trigger.removeEventListener("click", this.handleClick);
    // The copy sits next to (and is placed against) this trigger.
    if (this.popup && this.mountedTrigger === trigger) this.unmount();
  }

  contentTargetConnected() {
    if (this.ready) this.remount();
  }

  contentTargetDisconnected(template) {
    if (this.popup && this.mountedTemplate === template) this.unmount();
  }

  openValueChanged(open) {
    if (!this.ready) return;
    open ? this.open() : this.close();
  }

  disabledValueChanged(disabled) {
    if (this.ready && disabled) this.close();
  }

  // Kept for markup that still wires data-action to show/hide.
  show() {
    this.open();
  }

  hide() {
    this.close();
  }

  // --- Mounting -----------------------------------------------------------------

  mount() {
    if (this.popup || !this.hasContentTarget || !this.hasTriggerTarget) return;
    const template = this.contentTarget;
    const trigger = this.triggerTarget;
    const popup = template.content?.firstElementChild?.cloneNode(true);
    if (!popup) return;

    popup.addEventListener("mouseenter", this.handleEnter);
    popup.addEventListener("mouseleave", this.handleLeave);
    trigger.after(popup);
    this.popup = popup;
    this.mountedTrigger = trigger;
    this.mountedTemplate = template;
    this.describe(trigger, popup);
  }

  unmount() {
    const popup = this.popup;
    if (!popup) return;
    this.close({ animate: false });
    popup.removeEventListener("mouseenter", this.handleEnter);
    popup.removeEventListener("mouseleave", this.handleLeave);
    this.undescribe();
    popup.remove();
    this.popup = null;
    this.mountedTrigger = null;
    this.mountedTemplate = null;
  }

  remount() {
    const wasOpen = this.isOpen;
    this.unmount();
    this.mount();
    if (wasOpen) this.open();
  }

  // --- aria-describedby ---------------------------------------------------------

  // The element inside the trigger that receives focus (the Button), else the wrapper.
  controlFor(trigger) {
    return trigger.matches(FOCUSABLE) ? trigger : trigger.querySelector(FOCUSABLE) || trigger;
  }

  // Adds the content's id to the control's aria-describedby, keeping a
  // caller's own ids. Skipped when the tooltip only repeats the control's
  // text (SidebarMenuButton's label): the description would say it twice.
  describe(trigger, popup) {
    const control = this.controlFor(trigger);
    const text = (element) => element.textContent.replace(/\s+/g, " ").trim().toLowerCase();
    if (text(popup) !== "" && text(popup) === text(control)) return;

    const ids = (control.getAttribute("aria-describedby") || "").split(/\s+/).filter(Boolean);
    if (!ids.includes(popup.id)) control.setAttribute("aria-describedby", [...ids, popup.id].join(" "));
    this.describedControl = control;
  }

  undescribe() {
    const control = this.describedControl;
    this.describedControl = null;
    if (!control || !this.popup) return;
    const ids = (control.getAttribute("aria-describedby") || "").split(/\s+/).filter((id) => id && id !== this.popup.id);
    ids.length ? control.setAttribute("aria-describedby", ids.join(" ")) : control.removeAttribute("aria-describedby");
  }

  // --- Pointer, focus, click, Escape --------------------------------------------

  triggerSetting(key, fallback) {
    const own = this.mountedTrigger?.dataset[key];
    return own !== undefined && own !== "" ? own : fallback;
  }

  get openDelay() {
    return Number(this.triggerSetting("delay", 0)) || 0;
  }

  get closeDelay() {
    return Number(this.triggerSetting("closeDelay", 0)) || 0;
  }

  get closeOnClick() {
    return this.triggerSetting("closeOnClick", "true") !== "false";
  }

  handleEnter = (event) => {
    this.pointerInside = true;
    this.clearTimers();
    // After close_on_click, the pointer has to leave the trigger before it opens again.
    if (this.isOpen || this.pressedClosed || this.disabledValue) return;
    if (event.currentTarget === this.popup) return;
    const delay = this.openDelay;
    if (delay > 0) {
      this.openTimeout = setTimeout(() => this.open(), delay);
    } else {
      this.open();
    }
  };

  handleLeave = (event) => {
    this.pointerInside = false;
    if (event.currentTarget === this.mountedTrigger) this.pressedClosed = false;
    this.clearTimers();
    if (!this.isOpen || this.keyboardFocusInside()) return;
    this.closeTimeout = setTimeout(() => this.close(), this.closeDelay + HOVER_GRACE);
  };

  // Opens on keyboard focus only, as Base UI does: a click focuses the button too.
  handleFocusIn = (event) => {
    if (this.disabledValue || this.isOpen || !this.isFocusVisible(event.target)) return;
    this.clearTimers();
    this.open();
  };

  handleFocusOut = (event) => {
    if (this.mountedTrigger?.contains(event.relatedTarget)) return;
    if (this.pointerInside) return;
    this.close();
  };

  // Enter and Space on the trigger's button arrive here as a click too.
  handleClick = () => {
    if (!this.closeOnClick || !this.isOpen) return;
    this.pressedClosed = this.pointerInside;
    this.close();
  };

  handleKeydown = (event) => {
    if (event.key !== "Escape" || !this.isOpen) return;
    // Keeps an enclosing <dialog> from closing on the same key.
    event.preventDefault();
    this.close();
  };

  handleBeforeCache = () => {
    // The snapshot keeps the <template>; connect() places a fresh copy on restore.
    this.unmount();
  };

  keyboardFocusInside() {
    const active = document.activeElement;
    return Boolean(active && this.mountedTrigger?.contains(active) && this.isFocusVisible(active));
  }

  isFocusVisible(element) {
    try {
      return element.matches(":focus-visible");
    } catch {
      return true;
    }
  }

  clearTimers() {
    clearTimeout(this.openTimeout);
    clearTimeout(this.closeTimeout);
  }

  // --- Opening and closing ------------------------------------------------------

  open() {
    if (this.isOpen || this.disabledValue) return;
    this.mount();
    const popup = this.popup;
    if (!popup || !popup.isConnected) return;
    this.clearTimers();
    this.isOpen = true;

    // Side and origin before the enter animation starts; position() refines both.
    const { side, align } = this.preferredPlacement(popup);
    popup.dataset.side = side;
    popup.dataset.align = align;
    popup.removeAttribute("data-closed");
    popup.setAttribute("data-open", "");
    popup.dataset.state = "open";
    if (!popup.matches(":popover-open")) popup.showPopover();

    document.addEventListener("keydown", this.handleKeydown);
    this.startPositioning();
    this.setOpenValue(true);
  }

  close({ animate = true } = {}) {
    this.clearTimers();
    if (!this.isOpen) return;
    const popup = this.popup;
    this.isOpen = false;
    document.removeEventListener("keydown", this.handleKeydown);
    this.stopPositioning();

    popup.removeAttribute("data-open");
    popup.setAttribute("data-closed", "");
    popup.dataset.state = "closed";
    animate ? this.hideAfterExitAnimation(popup) : this.settleExit(popup);
    this.setOpenValue(false);
  }

  // Mirrors the state on the open value (so openValueChanged sees no change)
  // and tells listeners, as Base UI's onOpenChange does.
  setOpenValue(open) {
    if (this.openValue !== open) this.openValue = open;
    this.dispatch("change", { detail: { open } });
  }

  // --- Positioning --------------------------------------------------------------

  // TooltipContent side:/align:, else Tooltip placement:, else top/center.
  preferredPlacement(popup) {
    const [placementSide, placementAlign] = String(this.placementValue || "").split("-");
    const side = [popup.dataset.preferredSide, placementSide].find((value) => SIDES.includes(value)) || "top";
    const align = popup.dataset.preferredSide
      ? popup.dataset.preferredAlign || "center"
      : [popup.dataset.preferredAlign, placementAlign].find((value) => ALIGNS.includes(value)) || "center";
    return { side, align };
  }

  // inline-start / inline-end follow the trigger's writing direction.
  physicalSide(side, trigger) {
    if (!side.startsWith("inline-")) return side;
    const rtl = getComputedStyle(trigger).direction === "rtl";
    return (side === "inline-start") !== rtl ? "left" : "right";
  }

  startPositioning() {
    this.stopPositioning();
    const trigger = this.mountedTrigger;
    const popup = this.popup;
    const anchor = this.controlFor(trigger);
    this.cleanup = autoUpdate(anchor, popup, () => this.position(anchor, popup));
  }

  stopPositioning() {
    if (this.cleanup) this.cleanup();
    this.cleanup = null;
  }

  position(anchor, popup) {
    const { side, align } = this.preferredPlacement(popup);
    const physical = this.physicalSide(side, anchor);
    const placement = align === "center" ? physical : `${physical}-${align}`;
    const sideOffset = Number(popup.dataset.sideOffset ?? 4);
    const alignOffset = Number(popup.dataset.alignOffset ?? 0);
    const arrowElement = popup.querySelector('[data-slot="tooltip-arrow"]');

    const middleware = [
      // alignmentAxis flips the offset for align: :end, as Base UI does.
      offset({ mainAxis: sideOffset, alignmentAxis: alignOffset }),
      flip(),
      shift({ padding: 5 }),
    ];
    if (arrowElement) middleware.push(arrow({ element: arrowElement, padding: 5 }));

    computePosition(anchor, popup, { strategy: "fixed", placement, middleware }).then(
      ({ x, y, placement: resolved, middlewareData }) => {
        if (!popup.isConnected || popup !== this.popup || !this.isOpen) return;
        const [resolvedSide, resolvedAlign = "center"] = resolved.split("-");
        Object.assign(popup.style, { left: `${x}px`, top: `${y}px` });
        // A logical side keeps its logical name, flipped to the other one if Floating UI flipped.
        const finalSide = side.startsWith("inline-")
          ? resolvedSide === physical ? side : side === "inline-start" ? "inline-end" : "inline-start"
          : resolvedSide;
        popup.dataset.side = finalSide;
        popup.dataset.align = resolvedAlign;
        if (arrowElement) this.placeArrow(arrowElement, finalSide, resolvedSide, resolvedAlign, middlewareData.arrow);
        popup.style.setProperty("--transform-origin", this.transformOrigin(anchor, popup, resolvedSide, x, y, sideOffset));
      },
    );
  }

  // Along the trigger for top/bottom; the classes center it for left/right.
  placeArrow(arrowElement, side, physical, align, data = {}) {
    arrowElement.dataset.side = side;
    arrowElement.dataset.align = align;
    const vertical = physical === "top" || physical === "bottom";
    arrowElement.style.left = vertical && data.x != null ? `${data.x}px` : "";
    arrowElement.style.top = !vertical && data.y != null ? `${data.y}px` : "";
  }

  // The content grows out of the trigger: the origin sits on the trigger's
  // center line, at the gap between the two (Base UI's --transform-origin).
  transformOrigin(anchor, popup, side, x, y, sideOffset) {
    const rect = anchor.getBoundingClientRect();
    const { width, height } = popup.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2 - x;
    const centerY = rect.top + rect.height / 2 - y;
    switch (side) {
      case "top":
        return `${centerX}px ${height + sideOffset}px`;
      case "left":
        return `${width + sideOffset}px ${centerY}px`;
      case "right":
        return `${-sideOffset}px ${centerY}px`;
      default:
        return `${centerX}px ${-sideOffset}px`;
    }
  }

  // --- Exit animation (same block as the other overlay controllers) ------------

  exitAnimationNames = new WeakMap();

  hideAfterExitAnimation(animated) {
    const exitAnimations = animated.getAnimations().filter((animation) => animation instanceof CSSAnimation);
    // No exit animation, or no box to run it in (hidden by CSS): animationend would never fire.
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
    if (animated.matches(":popover-open")) animated.hidePopover();
  }
}
