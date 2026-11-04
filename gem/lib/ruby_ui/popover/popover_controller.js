import { Controller } from "@hotwired/stimulus";
import { computePosition, flip, shift, offset, autoUpdate } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--popover"
//
// Behaves like Base UI's Popover: a click, Enter or Space on the trigger
// toggles it, Escape or a click outside closes it. The trigger's focusable
// element carries aria-haspopup="dialog" and aria-expanded (aria-controls
// while open); the content is a role="dialog" named by PopoverTitle and
// described by PopoverDescription. Opening by click or keyboard moves focus
// into the content, and tabbing out of it closes it; closing returns focus
// to the trigger unless it already went somewhere else. With open_on_hover the pointer also opens it after a
// delay, and leaving both the trigger and the content closes it.
//
// The content is a native popover="manual", so it opens in the top layer and
// no ancestor with overflow: hidden clips it; Floating UI places it next to
// the trigger. Escape and outside clicks stay in JS (popover="auto" would hide
// it at once, skipping the exit animation, and treat a click on the trigger
// wrapper as an outside click).
const SIDES = ["top", "right", "bottom", "left", "inline-start", "inline-end"];
const ALIGNS = ["start", "center", "end"];
const FOCUSABLE = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
// The pointer needs a moment to cross the gap between trigger and content.
const HOVER_GRACE = 100;

export default class extends Controller {
  static targets = ["trigger", "content", "title", "description"];
  static values = {
    open: { type: Boolean, default: false },
    options: { type: Object, default: {} },
  };

  // The content while open: teardown uses it even if the content target has
  // left the DOM (e.g. a Turbo Stream replaced it).
  openContent = null;

  connect() {
    document.addEventListener("turbo:before-cache", this.handleBeforeCache);
    if (this.openValue) this.showPopover({ focus: false });
    this.ready = true;
  }

  // hidePopover() only touches openContent, never a target, so it can't throw here.
  disconnect() {
    this.ready = false;
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache);
    // Nothing is left to wait for the exit animation, so close at once.
    this.hidePopover({ animate: false, restoreFocus: false });
  }

  // Target callbacks run before connect() and again whenever Turbo or other
  // code swaps the trigger or the content inside a connected popover.
  triggerTargetConnected(trigger) {
    trigger.addEventListener("pointerdown", this.handlePress);
    trigger.addEventListener("click", this.handleClick);
    trigger.addEventListener("mouseenter", this.handleEnter);
    trigger.addEventListener("mouseleave", this.handleLeave);
    const control = this.controlFor(trigger);
    control.setAttribute("aria-haspopup", "dialog");
    control.setAttribute("aria-expanded", String(this.isOpen));
  }

  // Floating UI would keep placing the content against the detached trigger.
  triggerTargetDisconnected(trigger) {
    trigger.removeEventListener("pointerdown", this.handlePress);
    trigger.removeEventListener("click", this.handleClick);
    trigger.removeEventListener("mouseenter", this.handleEnter);
    trigger.removeEventListener("mouseleave", this.handleLeave);
    // A pending hover delay must not open the popover against a trigger nobody touched.
    this.clearTimers();
    if (this.isOpen) this.hidePopover({ animate: false, restoreFocus: false });
  }

  contentTargetConnected(content) {
    content.addEventListener("mouseenter", this.handleEnter);
    content.addEventListener("mouseleave", this.handleLeave);
    content.addEventListener("focusout", this.handleFocusOut);
    if (!content.id) content.id = `popover-content-${Math.random().toString(36).slice(2, 10)}`;
    this.labelContent(content);
    // A Turbo restore can bring back open content: settle on closed.
    if (content !== this.openContent) {
      content.removeAttribute("data-open");
      this.settleExit(content);
    }
  }

  // The open content was removed, or only lost its target attribute and is
  // still in the top layer: close that element at once and release the
  // listeners and Floating UI.
  contentTargetDisconnected(content) {
    content.removeEventListener("mouseenter", this.handleEnter);
    content.removeEventListener("mouseleave", this.handleLeave);
    content.removeEventListener("focusout", this.handleFocusOut);
    this.clearTimers();
    if (content === this.openContent) this.hidePopover({ animate: false, restoreFocus: false });
  }

  // A Turbo Stream can swap the title or the description on their own.
  titleTargetConnected() {
    this.relabel();
  }

  titleTargetDisconnected() {
    this.relabel();
  }

  descriptionTargetConnected() {
    this.relabel();
  }

  descriptionTargetDisconnected() {
    this.relabel();
  }

  relabel() {
    if (this.hasContentTarget) this.labelContent(this.contentTarget);
  }

  // Changing the open value from outside opens or closes the popover.
  openValueChanged(open) {
    if (!this.ready) return;
    this.clearTimers();
    open ? this.showPopover({ focus: false }) : this.hidePopover();
  }

  // --- Trigger and labels -------------------------------------------------------

  // The element inside the trigger that receives focus (the Button), else the wrapper.
  controlFor(trigger) {
    return trigger.matches(FOCUSABLE) ? trigger : trigger.querySelector(FOCUSABLE) || trigger;
  }

  get control() {
    return this.hasTriggerTarget ? this.controlFor(this.triggerTarget) : null;
  }

  // aria-controls only while open, as Base UI does: closed, the popup is hidden.
  syncTrigger(open) {
    const control = this.control;
    if (!control) return;
    control.setAttribute("aria-expanded", String(open));
    if (open && this.openContent?.id) {
      control.setAttribute("aria-controls", this.openContent.id);
    } else {
      control.removeAttribute("aria-controls");
    }
  }

  // The references this controller wrote, per content element, so a swapped
  // title or description updates them while a caller's own attribute is kept.
  generatedLabels = new WeakMap();

  // A caller's own aria-label / aria-labelledby / aria-describedby wins over
  // PopoverTitle and PopoverDescription.
  labelContent(content) {
    const generated = this.generatedLabels.get(content) || {};
    const title = this.titleTargets.find((element) => content.contains(element));
    const description = this.descriptionTargets.find((element) => content.contains(element));
    const labelOwned = !content.hasAttribute("aria-label") &&
      (!content.hasAttribute("aria-labelledby") || content.getAttribute("aria-labelledby") === generated.labelledby);
    generated.labelledby = labelOwned ? this.writeReference(content, "aria-labelledby", title?.id) : generated.labelledby;
    const descriptionOwned = !content.hasAttribute("aria-describedby") ||
      content.getAttribute("aria-describedby") === generated.describedby;
    generated.describedby = descriptionOwned
      ? this.writeReference(content, "aria-describedby", description?.id)
      : generated.describedby;
    this.generatedLabels.set(content, generated);
  }

  // Sets the attribute to id, or removes it when there is no id; returns what it wrote.
  writeReference(content, attribute, id) {
    if (id) {
      content.setAttribute(attribute, id);
      return id;
    }
    content.removeAttribute(attribute);
    return undefined;
  }

  // --- Hover --------------------------------------------------------------------

  // PopoverTrigger open_on_hover:, or the older Popover options trigger: "hover".
  get openOnHover() {
    if (!this.hasTriggerTarget) return false;
    const own = this.triggerTarget.dataset.openOnHover;
    if (own !== undefined) return own === "true";
    return this.optionsValue.trigger === "hover";
  }

  get openDelay() {
    return this.delayFor("delay", 300);
  }

  get closeDelay() {
    return this.delayFor("closeDelay", 0);
  }

  delayFor(key, fallback) {
    const own = this.hasTriggerTarget ? this.triggerTarget.dataset[key] : undefined;
    return own !== undefined && own !== "" ? Number(own) : fallback;
  }

  handleEnter = () => {
    if (!this.openOnHover) return;
    this.clearTimers();
    if (this.isOpen) return;
    this.openTimeout = setTimeout(() => this.showPopover({ focus: false }), this.openDelay);
  };

  handleLeave = () => {
    if (!this.openOnHover) return;
    this.clearTimers();
    if (!this.isOpen || !this.openedByHover) return;
    this.closeTimeout = setTimeout(() => this.hidePopover(), this.closeDelay + HOVER_GRACE);
  };

  clearTimers() {
    clearTimeout(this.openTimeout);
    clearTimeout(this.closeTimeout);
    clearTimeout(this.focusOutTimeout);
  }

  // --- Click, Escape, outside click ---------------------------------------------

  // Pressing the trigger moves focus out of the open content before the click
  // arrives; the click, not the focus change, decides whether it closes.
  handlePress = () => {
    this.pressingTrigger = true;
  };

  // Enter and Space on the trigger's button arrive here as a click too.
  handleClick = () => {
    this.pressingTrigger = false;
    this.clearTimers();
    // A click on a popover the pointer opened keeps it open (Base UI's sticky hover).
    if (this.isOpen && this.openedByHover) {
      this.openedByHover = false;
      return;
    }
    this.isOpen ? this.hidePopover() : this.showPopover();
  };

  handleKeydown = (event) => {
    if (event.key !== "Escape" || !this.isOpen) return;
    // Keeps an enclosing <dialog> from closing on the same key.
    event.preventDefault();
    this.hidePopover();
  };

  handleOutsideClick = (event) => {
    if (!this.isOpen || this.element.contains(event.target)) return;
    if (this.openContent?.contains(event.target)) return;
    this.hidePopover();
  };

  // Tab (or a script) moved focus out of the open content: close, as Base UI
  // does. A null relatedTarget is a click on nothing focusable or the window
  // losing focus; the outside-click handler covers the first.
  // Closes on the next task, once focus has landed: during focusout the
  // document still reports body as focused, and a "hide" listener (DatePicker)
  // would take that as lost focus and pull it back to the trigger.
  handleFocusOut = (event) => {
    const content = event.currentTarget;
    if (content !== this.openContent) return;
    const next = event.relatedTarget;
    if (!next || content.contains(next)) return;
    if (this.pressingTrigger && this.triggerTarget.contains(next)) return;
    clearTimeout(this.focusOutTimeout);
    this.focusOutTimeout = setTimeout(() => {
      if (content !== this.openContent || content.contains(document.activeElement)) return;
      this.hidePopover({ restoreFocus: false });
    });
  };

  handleBeforeCache = () => {
    this.clearTimers();
    if (this.isOpen) this.hidePopover({ animate: false, restoreFocus: false });
  };

  // --- Opening and closing ------------------------------------------------------

  get isOpen() {
    return this.openContent !== null;
  }

  // openValue is set here rather than by the callers, so a guarded early return
  // can never leave the DOM claiming the popover is open while nothing is wired up.
  showPopover({ focus = true } = {}) {
    if (!this.hasContentTarget || !this.hasTriggerTarget || this.isOpen) return;
    const content = (this.openContent = this.contentTarget);
    this.openedByHover = !focus && this.openOnHover;
    this.openValue = true;

    // Side and origin before the enter animation starts; position() refines both.
    const { side, align } = this.preferredPlacement(content);
    content.dataset.side = side;
    content.dataset.align = align;
    content.removeAttribute("data-closed");
    content.setAttribute("data-open", "");
    content.dataset.state = "open";
    if (!content.matches(":popover-open")) content.showPopover();

    document.addEventListener("keydown", this.handleKeydown);
    document.addEventListener("click", this.handleOutsideClick);
    this.startPositioning();
    this.syncTrigger(true);
    if (focus && !content.contains(document.activeElement)) content.focus({ preventScroll: true });
    // Lets a composite (DatePicker) follow the state, and move focus further in.
    this.dispatch("show");
  }

  hidePopover({ animate = true, restoreFocus = true } = {}) {
    const content = this.openContent;
    this.teardown();
    if (!content) return;
    this.openValue = false;
    this.openedByHover = false;
    this.syncTrigger(false);

    // Back to the trigger, unless focus already moved somewhere else (another field).
    const active = document.activeElement;
    const focusLost = !active || active === document.body || content.contains(active);
    if (restoreFocus && focusLost) this.control?.focus({ preventScroll: true });

    content.removeAttribute("data-open");
    content.setAttribute("data-closed", "");
    content.dataset.state = "closed";
    animate ? this.hideAfterExitAnimation(content) : this.settleExit(content);
    this.dispatch("hide");
  }

  // Everything showPopover() started: timers, the document listeners, Floating UI.
  teardown() {
    this.clearTimers();
    document.removeEventListener("keydown", this.handleKeydown);
    document.removeEventListener("click", this.handleOutsideClick);
    this.stopPositioning();
    this.openContent = null;
  }

  // --- Positioning --------------------------------------------------------------

  // PopoverContent side:/align:, else Popover options placement:, else bottom/center.
  preferredPlacement(content) {
    const [optionSide, optionAlign] = String(this.optionsValue.placement || "").split("-");
    const side = [content.dataset.preferredSide, optionSide].find((value) => SIDES.includes(value)) || "bottom";
    const align = content.dataset.preferredSide
      ? content.dataset.preferredAlign || "center"
      : [content.dataset.preferredAlign, optionAlign].find((value) => ALIGNS.includes(value)) || "center";
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
    const trigger = this.triggerTarget;
    const content = this.openContent;
    this.cleanup = autoUpdate(trigger, content, () => this.position(trigger, content));
  }

  stopPositioning() {
    if (this.cleanup) this.cleanup();
    this.cleanup = null;
  }

  position(trigger, content) {
    const { side, align } = this.preferredPlacement(content);
    const physical = this.physicalSide(side, trigger);
    const placement = align === "center" ? physical : `${physical}-${align}`;
    const sideOffset = Number(content.dataset.sideOffset ?? 4);
    const alignOffset = Number(content.dataset.alignOffset ?? 0);

    computePosition(trigger, content, {
      strategy: "fixed",
      placement,
      middleware: [
        // alignmentAxis flips the offset for align: :end, as Base UI does.
        offset({ mainAxis: sideOffset, alignmentAxis: alignOffset }),
        flip(),
        shift({ padding: 5 }),
      ],
    }).then(({ x, y, placement: resolved }) => {
      if (!content.isConnected || content !== this.openContent) return;
      const [resolvedSide, resolvedAlign = "center"] = resolved.split("-");
      Object.assign(content.style, { left: `${x}px`, top: `${y}px` });
      // A logical side keeps its logical name, flipped to the other one if Floating UI flipped.
      content.dataset.side = side.startsWith("inline-")
        ? resolvedSide === physical ? side : side === "inline-start" ? "inline-end" : "inline-start"
        : resolvedSide;
      content.dataset.align = resolvedAlign;
      content.style.setProperty("--transform-origin", this.transformOrigin(trigger, content, resolvedSide, x, y, sideOffset));
    });
  }

  // The content grows out of the trigger: the origin sits on the trigger's
  // center line, at the gap between the two (Base UI's --transform-origin).
  transformOrigin(trigger, content, side, x, y, sideOffset) {
    const anchor = trigger.getBoundingClientRect();
    const { width, height } = content.getBoundingClientRect();
    const centerX = anchor.left + anchor.width / 2 - x;
    const centerY = anchor.top + anchor.height / 2 - y;
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
    if (animated.matches(":popover-open")) animated.hidePopover();
  }
}
