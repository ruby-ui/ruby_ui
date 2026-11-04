import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, flip, shift, size } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--select"
//
// Follows Base UI's Select: the trigger is a role=combobox button, the list a
// role=listbox native popover, and DOM focus moves onto the options (roving
// tabindex). SelectInput holds the value for forms and FormField.
export default class extends Controller {
  static targets = ["trigger", "value", "content", "input", "item"];

  connect() {
    this.cleanup = null;
    this.focusReturn = null;
    this.typeahead = "";
    this.mirroredInvalid = false;
    this.mirroredDescribedBy = false;
    // FormField marks the hidden input aria-invalid; mirror it on the trigger,
    // so the error is announced and styled where people look.
    this.invalidObserver = new MutationObserver(() => this.syncInvalid());
    if (this.hasInputTarget) {
      this.invalidObserver.observe(this.inputTarget, { attributes: true, attributeFilter: ["aria-invalid", "aria-describedby"] });
    }
    // The form's reset restores the input without firing change.
    this.form = this.element.closest("form");
    this.form?.addEventListener("reset", this.handleFormReset);
    this.assignOptionIds();
    this.syncSelection();
    this.syncInvalid();
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    this.removeFocusReturn();
    this.invalidObserver?.disconnect();
    this.form?.removeEventListener("reset", this.handleFormReset);
    clearTimeout(this.resetTimeout);
    clearTimeout(this.typeaheadTimeout);
    this.stopAutoUpdate();
    if (this.hasContentTarget && this.contentTarget.matches(":popover-open")) this.contentTarget.hidePopover();
  }

  itemTargetConnected() {
    this.assignOptionIds();
  }

  handleFormReset = () => {
    clearTimeout(this.resetTimeout);
    this.resetTimeout = setTimeout(() => this.syncSelection());
  };

  // --- Opening and closing ----------------------------------------------------

  get isOpen() {
    return this.hasContentTarget && this.contentTarget.hasAttribute("data-open");
  }

  toggle(event) {
    event?.preventDefault();
    this.isOpen ? this.hide({ restoreFocus: true }) : this.show();
  }

  // Enter and Space reach toggle through the button's click.
  triggerKeydown(event) {
    if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
    event.preventDefault();
    if (!this.isOpen) this.show();
  }

  show() {
    if (!this.hasContentTarget || this.isOpen || this.triggerTarget.disabled) return;
    if (this.triggerTarget.getAttribute("aria-disabled") === "true") return;

    const content = this.contentTarget;
    content.removeAttribute("data-closed");
    content.setAttribute("data-open", "");
    if (!content.matches(":popover-open")) content.showPopover();
    this.setExpanded(true);
    this.position();
    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);

    // Like Base UI: the selected option takes focus; with nothing selected the
    // list itself does, and no option is highlighted until a key or hover.
    const selected = this.selectedItem;
    if (selected && !this.isDisabled(selected)) this.focusItem(selected);
    else content.focus({ preventScroll: true });
  }

  hide({ restoreFocus = false } = {}) {
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    this.stopAutoUpdate();
    this.setExpanded(false);
    this.resetTypeahead();
    if (!this.hasContentTarget) return;

    const content = this.contentTarget;
    content.removeAttribute("data-open");
    content.setAttribute("data-closed", "");
    if (content.matches(":popover-open")) content.hidePopover();
    if (restoreFocus) this.triggerTarget.focus();
  }

  setExpanded(open) {
    this.triggerTarget.setAttribute("aria-expanded", open ? "true" : "false");
    // Like Base UI, the trigger points at the list only while it is open.
    if (open && this.hasContentTarget) this.triggerTarget.setAttribute("aria-controls", this.contentTarget.id);
    else this.triggerTarget.removeAttribute("aria-controls");
  }

  handleOutsidePointerDown = (event) => {
    if (this.element.contains(event.target)) return;
    const focusWasInside = this.element.contains(document.activeElement);
    this.hide();
    // Like Base UI, focus goes back to the trigger unless the click lands on
    // something that takes focus itself.
    this.removeFocusReturn();
    if (focusWasInside) {
      const trigger = this.triggerTarget;
      this.focusReturn = () => {
        this.focusReturn = null;
        if (document.activeElement === document.body || !document.activeElement) trigger.focus();
      };
      document.addEventListener("click", this.focusReturn, { once: true, capture: true });
    }
  };

  // A pointerdown with no click (a touch scroll) would otherwise leave it armed.
  removeFocusReturn() {
    if (!this.focusReturn) return;
    document.removeEventListener("click", this.focusReturn, { capture: true });
    this.focusReturn = null;
  }

  // --- Keyboard -------------------------------------------------------------

  listKeydown(event) {
    if (!this.isOpen) return;
    const options = this.enabledOptions;
    const current = options.indexOf(document.activeElement);

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        // No wrap at the ends, as Base UI.
        this.focusItem(current === -1 ? options[0] : options[Math.min(current + 1, options.length - 1)]);
        break;
      case "ArrowUp":
        event.preventDefault();
        this.focusItem(current === -1 ? options[options.length - 1] : options[Math.max(current - 1, 0)]);
        break;
      case "Home":
        event.preventDefault();
        this.focusItem(options[0]);
        break;
      case "End":
        event.preventDefault();
        this.focusItem(options[options.length - 1]);
        break;
      case "Enter":
        event.preventDefault();
        if (current !== -1) this.choose(options[current]);
        break;
      case " ":
        event.preventDefault();
        // Space is part of a typeahead query while one is being typed.
        if (this.typeahead) this.typeaheadTo(" ");
        else if (current !== -1) this.choose(options[current]);
        break;
      case "Escape":
        event.preventDefault();
        event.stopPropagation();
        this.hide({ restoreFocus: true });
        break;
      case "Tab":
        // Like Base UI: Shift+Tab closes onto the trigger; Tab returns focus
        // to the trigger first, so the browser moves on from there.
        if (event.shiftKey) event.preventDefault();
        this.hide({ restoreFocus: true });
        break;
      default:
        if (event.key.length === 1 && !event.ctrlKey && !event.metaKey && !event.altKey) {
          event.preventDefault();
          this.typeaheadTo(event.key);
        }
    }
  }

  // Typing jumps to the next option whose text starts with what was typed;
  // the same letter repeated cycles through the options that start with it.
  typeaheadTo(key) {
    clearTimeout(this.typeaheadTimeout);
    this.typeahead += key.toLowerCase();
    this.typeaheadTimeout = setTimeout(() => this.resetTypeahead(), 500);

    const options = this.enabledOptions;
    const repeated = this.typeahead.split("").every((char) => char === this.typeahead[0]);
    const query = repeated ? this.typeahead[0] : this.typeahead;
    const start = options.indexOf(document.activeElement);
    const ordered = [...options.slice(start + 1), ...options.slice(0, start + 1)];
    const pool = repeated || start === -1 ? ordered : [options[start], ...ordered];
    const match = pool.find((option) => this.textOf(option).toLowerCase().startsWith(query));
    if (match) this.focusItem(match);
  }

  resetTypeahead() {
    clearTimeout(this.typeaheadTimeout);
    this.typeahead = "";
  }

  hover(event) {
    const option = event.currentTarget;
    if (option !== document.activeElement && !this.isDisabled(option)) this.focusItem(option, { scroll: false });
  }

  focusItem(option, { scroll = true } = {}) {
    if (!option) return;
    option.focus({ preventScroll: true });
    if (scroll) option.scrollIntoView({ block: "nearest" });
  }

  // The browser focuses the first invalid control after the invalid event;
  // the hidden input can't be seen, so focus moves on to the trigger, as Base UI.
  focusTrigger() {
    setTimeout(() => {
      if (document.activeElement === this.inputTarget) this.triggerTarget.focus();
    });
  }

  // --- Selection --------------------------------------------------------------

  select(event) {
    this.choose(event.currentTarget);
  }

  choose(option) {
    if (!option || this.isDisabled(option)) return;

    const input = this.hasInputTarget ? this.inputTarget : null;
    const changed = input && input.value !== option.dataset.value;
    if (input) input.value = option.dataset.value;
    this.syncSelection();
    if (changed) {
      input.dispatchEvent(new Event("input", { bubbles: true }));
      input.dispatchEvent(new Event("change", { bubbles: true }));
    }
    this.hide({ restoreFocus: true });
  }

  syncSelection() {
    const selected = this.selectedItem;
    this.itemTargets.forEach((item) => item.setAttribute("aria-selected", item === selected ? "true" : "false"));

    const placeholder = !selected;
    this.triggerTarget.toggleAttribute("data-placeholder", placeholder);
    if (!this.hasValueTarget) return;

    const value = this.valueTarget;
    value.toggleAttribute("data-placeholder", placeholder);
    if (selected) value.textContent = this.textOf(selected);
    else if (value.dataset.placeholderText !== undefined) value.textContent = value.dataset.placeholderText;
  }

  syncInvalid() {
    if (!this.hasInputTarget) return;
    const trigger = this.triggerTarget;

    const describedBy = this.inputTarget.getAttribute("aria-describedby");
    if (describedBy && (!trigger.hasAttribute("aria-describedby") || this.mirroredDescribedBy)) {
      trigger.setAttribute("aria-describedby", describedBy);
      this.mirroredDescribedBy = true;
    }

    if (this.inputTarget.getAttribute("aria-invalid") === "true") {
      if (trigger.getAttribute("aria-invalid") === "true") return;
      trigger.setAttribute("aria-invalid", "true");
      this.mirroredInvalid = true;
    } else if (this.mirroredInvalid) {
      // Only undo what we set: an author's own aria-invalid stays.
      trigger.removeAttribute("aria-invalid");
      this.mirroredInvalid = false;
    }
  }

  // --- Helpers --------------------------------------------------------------

  get selectedItem() {
    if (!this.hasInputTarget || this.inputTarget.value === "") return null;
    return this.itemTargets.find((item) => item.dataset.value === this.inputTarget.value) || null;
  }

  get enabledOptions() {
    return this.itemTargets.filter((item) => !this.isDisabled(item));
  }

  textOf(item) {
    return item.textContent.trim();
  }

  isDisabled(option) {
    return option.hasAttribute("data-disabled") || option.getAttribute("aria-disabled") === "true";
  }

  assignOptionIds() {
    const prefix = (this.hasContentTarget && this.contentTarget.id) || "select";
    let next = 0;
    this.itemTargets.forEach((item) => {
      if (item.id) return;
      while (document.getElementById(`${prefix}-option-${next}`)) next++;
      item.id = `${prefix}-option-${next}`;
    });
  }

  // --- Positioning ----------------------------------------------------------

  position() {
    this.stopAutoUpdate();
    const anchor = this.triggerTarget;
    const content = this.contentTarget;
    const side = content.dataset.preferredSide || "bottom";
    const align = content.dataset.align || "center";
    const placement = align === "center" ? side : `${side}-${align}`;
    const sideOffset = Number(content.dataset.sideOffset ?? 4);
    const alignOffset = Number(content.dataset.alignOffset ?? 0);

    this.cleanup = autoUpdate(anchor, content, () => {
      if (!anchor.isConnected || !content.isConnected) return;

      computePosition(anchor, content, {
        strategy: "fixed",
        placement,
        middleware: [
          offset({ mainAxis: sideOffset, crossAxis: alignOffset }),
          flip(),
          shift({ padding: 5 }),
          size({
            padding: 5,
            apply({ availableHeight, rects }) {
              content.style.setProperty("--anchor-width", `${rects.reference.width}px`);
              content.style.setProperty("--available-height", `${availableHeight}px`);
            },
          }),
        ],
      }).then(({ x, y, placement: resolved }) => {
        if (!content.isConnected) return;
        const [resolvedSide, resolvedAlign] = resolved.split("-");
        Object.assign(content.style, { left: `${x}px`, top: `${y}px` });
        content.dataset.side = resolvedSide;
        content.style.setProperty("--transform-origin", this.transformOrigin(resolvedSide, resolvedAlign));
      });
    });
  }

  transformOrigin(side, align) {
    const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" }[side];
    const vertical = side === "top" || side === "bottom";
    const cross = { start: vertical ? "left" : "top", end: vertical ? "right" : "bottom" }[align] || "center";
    return vertical ? `${cross} ${opposite}` : `${opposite} ${cross}`;
  }

  stopAutoUpdate() {
    this.cleanup?.();
    this.cleanup = null;
  }
}
