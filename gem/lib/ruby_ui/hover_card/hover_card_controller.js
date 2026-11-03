import { Controller } from "@hotwired/stimulus";
import { computePosition, flip, shift, offset, autoUpdate } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--hover-card"
//
// Behaves like Base UI's PreviewCard: hovering or focusing the trigger opens
// the card after a delay, moving the pointer onto the card keeps it open, and
// leaving both (or Escape) closes it after the close delay. The card is a
// native popover="manual", so it opens in the top layer and no ancestor with
// overflow: hidden clips it; Floating UI places it next to the trigger.
const SIDES = ["top", "right", "bottom", "left"];
const ALIGNS = ["start", "center", "end"];

export default class extends Controller {
  static targets = ["trigger", "content"];
  static values = {
    open: { type: Boolean, default: false },
    options: { type: Object, default: {} },
    // make content width match the trigger element (true/false)
    matchWidth: { type: Boolean, default: false },
  };

  // The card while open: teardown uses it even if the content target has
  // left the DOM (e.g. a Turbo Stream replaced it).
  openContent = null;

  connect() {
    document.addEventListener("turbo:before-cache", this.handleBeforeCache);
    if (this.openValue) this.show();
    this.ready = true;
  }

  // hide() only touches openContent, never a target, so it can't throw here.
  disconnect() {
    this.ready = false;
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache);
    // Nothing is left to wait for the exit animation, so close at once.
    this.hide({ animate: false });
  }

  // Target callbacks run before connect() and again whenever Turbo or other
  // code swaps the trigger or the card inside a connected hover card.
  triggerTargetConnected(trigger) {
    this.listen(trigger);
  }

  triggerTargetDisconnected(trigger) {
    this.unlisten(trigger);
  }

  contentTargetConnected(content) {
    this.listen(content);
    // A Turbo restore can bring back an open card: settle on closed.
    if (content !== this.openContent) {
      content.removeAttribute("data-open");
      this.settleExit(content);
    }
  }

  // The open card was removed on its own: release the listeners and Floating UI.
  contentTargetDisconnected(content) {
    this.unlisten(content);
    if (content === this.openContent) this.teardown();
  }

  // Changing the open value from outside opens or closes the card.
  openValueChanged(open) {
    if (!this.ready) return;
    this.clearTimers();
    open ? this.show() : this.hide();
  }

  // --- Delays -----------------------------------------------------------------

  // HoverCardTrigger delay:/close_delay: win; then HoverCard option delay:
  // (a number or an [open, close] tuple); then Base UI's 600/300.
  get openDelay() {
    return this.delayFor("delay", 0, 600);
  }

  get closeDelay() {
    return this.delayFor("closeDelay", 1, 300);
  }

  delayFor(key, index, fallback) {
    const own = this.hasTriggerTarget ? this.triggerTarget.dataset[key] : undefined;
    if (own !== undefined && own !== "") return Number(own);
    const delay = this.optionsValue.delay;
    if (Array.isArray(delay)) return delay[index] ?? fallback;
    if (typeof delay === "number") return delay;
    return fallback;
  }

  // --- Listeners ----------------------------------------------------------------

  listen(element) {
    element.addEventListener("mouseenter", this.handleEnter);
    element.addEventListener("mouseleave", this.handleLeave);
    element.addEventListener("focusin", this.handleEnter);
    element.addEventListener("focusout", this.handleLeave);
  }

  unlisten(element) {
    element.removeEventListener("mouseenter", this.handleEnter);
    element.removeEventListener("mouseleave", this.handleLeave);
    element.removeEventListener("focusin", this.handleEnter);
    element.removeEventListener("focusout", this.handleLeave);
  }

  handleEnter = () => {
    this.clearTimers();
    if (this.isOpen) return;
    this.openTimeout = setTimeout(() => this.show(), this.openDelay);
  };

  handleLeave = () => {
    this.clearTimers();
    if (!this.isOpen) return;
    this.closeTimeout = setTimeout(() => this.hide(), this.closeDelay);
  };

  handleKeydown = (event) => {
    if (event.key === "Escape") this.hide();
  };

  handleBeforeCache = () => {
    this.clearTimers();
    if (this.isOpen) this.hide({ animate: false });
  };

  clearTimers() {
    clearTimeout(this.openTimeout);
    clearTimeout(this.closeTimeout);
  }

  // --- Opening and closing ------------------------------------------------------

  get isOpen() {
    return this.openContent !== null;
  }

  show() {
    if (!this.hasContentTarget || !this.hasTriggerTarget || this.isOpen) return;
    const content = (this.openContent = this.contentTarget);
    this.openValue = true;

    // Side and origin before the enter animation starts; position() refines both.
    const { side, align } = this.preferredPlacement(content);
    content.dataset.side = side;
    content.dataset.align = align;
    content.removeAttribute("data-closed");
    content.setAttribute("data-open", "");
    content.dataset.state = "open";
    if (this.matchWidthValue) content.style.width = `${this.triggerTarget.offsetWidth}px`;
    if (!content.matches(":popover-open")) content.showPopover();

    document.addEventListener("keydown", this.handleKeydown);
    this.startPositioning();
  }

  hide({ animate = true } = {}) {
    const content = this.openContent;
    this.teardown();
    if (!content) return;
    this.openValue = false;

    content.removeAttribute("data-open");
    content.setAttribute("data-closed", "");
    content.dataset.state = "closed";
    animate ? this.hideAfterExitAnimation(content) : this.settleExit(content);
  }

  // Everything show() started: timers, the Escape listener, Floating UI.
  teardown() {
    this.clearTimers();
    document.removeEventListener("keydown", this.handleKeydown);
    this.stopPositioning();
    this.openContent = null;
  }

  // --- Positioning --------------------------------------------------------------

  // HoverCardContent side:/align:, else HoverCard option placement:, else bottom/center.
  preferredPlacement(content) {
    const [optionSide, optionAlign] = String(this.optionsValue.placement || "").split("-");
    const side = [content.dataset.preferredSide, optionSide].find((value) => SIDES.includes(value)) || "bottom";
    const align = content.dataset.preferredSide
      ? content.dataset.preferredAlign || "center"
      : [content.dataset.preferredAlign, optionAlign].find((value) => ALIGNS.includes(value)) || "center";
    return { side, align };
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
    const placement = align === "center" ? side : `${side}-${align}`;
    const sideOffset = Number(content.dataset.sideOffset ?? 4);
    const alignOffset = Number(content.dataset.alignOffset ?? 4);

    computePosition(trigger, content, {
      strategy: "fixed",
      placement,
      middleware: [
        // alignmentAxis flips the offset for align: :end, as Base UI does.
        offset({ mainAxis: sideOffset, crossAxis: alignOffset, alignmentAxis: alignOffset }),
        flip(),
        shift({ padding: 5 }),
      ],
    }).then(({ x, y, placement: resolved }) => {
      if (!content.isConnected || content !== this.openContent) return;
      const [resolvedSide, resolvedAlign = "center"] = resolved.split("-");
      Object.assign(content.style, { left: `${x}px`, top: `${y}px` });
      content.dataset.side = resolvedSide;
      content.dataset.align = resolvedAlign;
      content.style.setProperty("--transform-origin", this.transformOrigin(trigger, content, resolvedSide, x, y, sideOffset));
    });
  }

  // The card grows out of the trigger: the origin sits on the trigger's
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
