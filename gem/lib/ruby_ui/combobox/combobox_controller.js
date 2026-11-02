import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, flip, shift, size } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--combobox"
//
// Follows the APG combobox pattern as Base UI does: focus stays in the text
// input, the active option is announced through aria-activedescendant and
// marked data-highlighted. Each option carries a native radio/checkbox, so the
// selection is whatever is checked and the form submits it as is.
export default class extends Controller {
  static values = {
    multiple: { type: Boolean, default: false },
    term: String,
  };

  static targets = [
    "trigger",
    "value",
    "input",
    "clear",
    "content",
    "list",
    "item",
    "group",
    "separator",
    "toggleAll",
    "chips",
    "chipTemplate",
  ];

  connect() {
    this.cleanup = null;
    this.highlighted = null;
    this.focusReturn = null;
    this.mirroredInvalid = false;
    this.mirroredDescribedBy = false;
    // A reconnect can bring back an option marked by a previous instance.
    this.element.querySelectorAll("[data-highlighted]").forEach((option) => option.removeAttribute("data-highlighted"));
    if (this.hasChipsTarget && this.hasContentTarget) this.contentTarget.dataset.chips = "true";
    // FormField marks the hidden radios/checkboxes aria-invalid; mirror it on
    // the control people see, so the error is announced and styled there.
    this.invalidObserver = new MutationObserver(() => this.syncInvalid());
    this.invalidObserver.observe(this.element, { subtree: true, attributes: true, attributeFilter: ["aria-invalid", "aria-describedby"] });
    // The form's reset unchecks the inputs without firing change.
    this.form = this.element.closest("form");
    this.form?.addEventListener("reset", this.handleFormReset);
    this.syncInvalid();
    this.refresh();
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    this.removeFocusReturn();
    this.invalidObserver?.disconnect();
    this.form?.removeEventListener("reset", this.handleFormReset);
    clearTimeout(this.resetTimeout);
    this.stopAutoUpdate();
    if (this.hasContentTarget) this.settleExit(this.contentTarget);
  }

  // Re-reads the DOM (connect, Turbo morph): option ids, the popup state the
  // server markup may have reset, and the checked inputs.
  refresh() {
    this.assignOptionIds();
    if (this.hasListTarget && this.listTarget.id) {
      this.inputTargets.forEach((input) => input.setAttribute("aria-controls", this.listTarget.id));
    }
    if (this.hasContentTarget) {
      const content = this.contentTarget;
      // A morph can restore data-closed while the native popover is still open
      // (or the reverse): settle on closed, with the listeners released.
      if (content.matches(":popover-open") !== content.hasAttribute("data-open") || this.isOpen) {
        this.hide({ restoreFocus: false, animate: false });
      }
    }
    this.syncSelection();
    if (this.inputIsTrigger && !this.multipleValue) this.inputTarget.value = this.selectedText;
  }

  itemTargetConnected() {
    this.assignOptionIds();
  }

  // reset fires before the form restores its controls; the next task sees the
  // restored checked state.
  handleFormReset = () => {
    clearTimeout(this.resetTimeout);
    this.resetTimeout = setTimeout(() => {
      this.refresh();
      // Lets CheckboxGroup (required multiple:) recompute its required flags.
      const first = this.itemTargets.map((item) => this.inputOf(item)).find(Boolean);
      if (first?.type === "checkbox") first.dispatchEvent(new Event("change", { bubbles: true }));
    });
  };

  syncInvalid() {
    const control = this.hasTriggerTarget ? this.triggerTarget : this.hasInputTarget ? this.inputTarget : null;
    if (!control) return;

    // FormField points its hint and error at the hidden inputs.
    const describedBy = this.itemTargets.map((item) => this.inputOf(item)?.getAttribute("aria-describedby")).find(Boolean);
    if (describedBy && (!control.hasAttribute("aria-describedby") || this.mirroredDescribedBy)) {
      if (control.getAttribute("aria-describedby") !== describedBy) control.setAttribute("aria-describedby", describedBy);
      this.mirroredDescribedBy = true;
    }

    const invalid = this.itemTargets.some((item) => this.inputOf(item)?.getAttribute("aria-invalid") === "true");
    if (invalid) {
      if (control.getAttribute("aria-invalid") === "true") return;
      control.setAttribute("aria-invalid", "true");
      this.mirroredInvalid = true;
    } else if (this.mirroredInvalid) {
      // Only undo what we set: an author's own aria-invalid stays.
      control.removeAttribute("aria-invalid");
      this.mirroredInvalid = false;
    }
  }

  // --- Modes -----------------------------------------------------------------

  get isOpen() {
    return this.hasContentTarget && this.contentTarget.hasAttribute("data-open");
  }

  // The input sits outside the popup when it is the trigger (input or chips).
  get inputIsTrigger() {
    return this.hasInputTarget && !this.contentTarget.contains(this.inputTarget);
  }

  get anchor() {
    if (this.hasChipsTarget) return this.chipsTarget;
    if (this.hasTriggerTarget) return this.triggerTarget;
    return this.inputTarget.closest("[data-slot=input-group]") || this.inputTarget;
  }

  get disabled() {
    return this.element.dataset.disabled === "true";
  }

  // --- Opening and closing ----------------------------------------------------

  toggle(event) {
    event?.preventDefault();
    this.isOpen ? this.hide({ restoreFocus: true }) : this.show();
  }

  triggerKeydown(event) {
    if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
    event.preventDefault();
    if (!this.isOpen) this.show({ highlight: event.key === "ArrowDown" ? "first" : "last" });
  }

  inputClick() {
    if (this.inputIsTrigger && !this.isOpen) this.show();
  }

  focusInput(event) {
    if (event.target.closest("button")) return;
    this.inputTarget.focus();
    if (!this.isOpen) this.show();
  }

  show({ highlight = null } = {}) {
    if (this.disabled || !this.hasContentTarget || this.isOpen) return;

    const content = this.contentTarget;
    content.removeAttribute("data-closed");
    content.setAttribute("data-open", "");
    if (!content.matches(":popover-open")) content.showPopover();
    this.setExpanded(true);
    this.applyFilter("");
    this.position();
    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);

    if (!this.inputIsTrigger && this.hasInputTarget) {
      this.inputTarget.value = "";
      this.inputTarget.focus();
    } else if (this.hasInputTarget && document.activeElement !== this.inputTarget) {
      // Opened from the chevron: keys only reach the input.
      this.inputTarget.focus();
    }

    const options = this.visibleOptions;
    if (highlight === "first") this.highlight(options[0]);
    else if (highlight === "last") this.highlight(options[options.length - 1]);
    else this.highlight(options.find((option) => option.getAttribute("aria-selected") === "true"));
  }

  hide({ restoreFocus = false, animate = true } = {}) {
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    this.stopAutoUpdate();
    this.setExpanded(false);
    this.highlight(null);
    if (!this.hasContentTarget) return;

    const content = this.contentTarget;
    content.removeAttribute("data-open");
    content.setAttribute("data-closed", "");
    animate ? this.hideAfterExitAnimation(content) : this.settleExit(content);

    if (this.inputIsTrigger) {
      // Typing doesn't change the value: the input goes back to the selection.
      this.inputTarget.value = this.multipleValue ? "" : this.selectedText;
    }
    if (restoreFocus) (this.hasTriggerTarget ? this.triggerTarget : this.inputTarget)?.focus();
  }

  setExpanded(open) {
    const value = open ? "true" : "false";
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", value);
      // Like Base UI, the trigger points at the popup only while it is open.
      if (open && this.hasContentTarget && this.contentTarget.id) {
        this.triggerTarget.setAttribute("aria-controls", this.contentTarget.id);
      } else {
        this.triggerTarget.removeAttribute("aria-controls");
      }
    }
    if (this.hasInputTarget) this.inputTarget.setAttribute("aria-expanded", value);
  }

  handleOutsidePointerDown = (event) => {
    if (this.element.contains(event.target)) return;
    const focusWasInside = this.element.contains(document.activeElement);
    this.hide();
    // Like Base UI, focus goes back to the trigger unless the click lands on
    // something that takes focus itself.
    this.removeFocusReturn();
    if (focusWasInside && this.hasTriggerTarget) {
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

  // Clicking an option must not move focus away from the input.
  keepFocus(event) {
    event.preventDefault();
  }

  // --- Keyboard -------------------------------------------------------------

  inputKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.isOpen ? this.move(1) : this.show({ highlight: "first" });
        break;
      case "ArrowUp":
        event.preventDefault();
        this.isOpen ? this.move(-1) : this.show({ highlight: "last" });
        break;
      case "Home":
      case "End": {
        if (!this.isOpen) return;
        // Like Base UI: jump to the first/last option. The caret still moves
        // when there is text; on an empty input the browser would scroll the
        // page instead, so that default is dropped.
        if (this.inputTarget.value === "") event.preventDefault();
        const options = this.visibleOptions;
        this.highlight(event.key === "Home" ? options[0] : options[options.length - 1]);
        break;
      }
      case "Enter":
        if (!this.isOpen) return;
        event.preventDefault();
        if (this.highlighted) this.choose(this.highlighted);
        break;
      case "Escape":
        if (!this.isOpen) return;
        event.preventDefault();
        event.stopPropagation();
        this.hide({ restoreFocus: true });
        break;
      case "Tab":
        if (this.isOpen) this.hide();
        break;
      case "Backspace":
        if (this.hasChipsTarget && this.inputTarget.value === "") this.removeLastSelected();
        break;
    }
  }

  move(delta) {
    const options = this.visibleOptions;
    if (options.length === 0) return;
    const index = options.indexOf(this.highlighted);
    const next = index === -1 ? (delta > 0 ? 0 : options.length - 1) : (index + delta + options.length) % options.length;
    this.highlight(options[next]);
  }

  hover(event) {
    const option = event.currentTarget;
    if (option !== this.highlighted && !this.isDisabled(option)) this.highlight(option, { scroll: false });
  }

  highlight(option, { scroll = true } = {}) {
    this.highlighted?.removeAttribute("data-highlighted");
    this.highlighted = option || null;
    if (!this.hasInputTarget) return;

    if (!option) {
      this.inputTarget.removeAttribute("aria-activedescendant");
      return;
    }
    option.setAttribute("data-highlighted", "");
    this.inputTarget.setAttribute("aria-activedescendant", option.id);
    if (scroll) option.scrollIntoView({ block: "nearest" });
  }

  // --- Filtering --------------------------------------------------------------

  filter() {
    if (!this.isOpen) this.show();
    this.applyFilter(this.inputTarget.value);
    this.highlight(null);
  }

  applyFilter(query) {
    const term = query.trim().toLowerCase();
    let visible = 0;

    this.itemTargets.forEach((item) => {
      const match = this.textOf(item).toLowerCase().includes(term);
      item.hidden = !match;
      if (match) visible++;
    });
    this.groupTargets.forEach((group) => {
      group.hidden = !this.itemTargets.some((item) => !item.hidden && group.contains(item));
    });
    this.separatorTargets.forEach((separator) => (separator.hidden = term !== ""));
    this.toggleAllTargets.forEach((toggleAll) => (toggleAll.hidden = term !== ""));

    const empty = visible === 0;
    for (const element of [this.hasContentTarget && this.contentTarget, this.hasListTarget && this.listTarget]) {
      if (element) element.toggleAttribute("data-empty", empty);
    }
  }

  // --- Selection --------------------------------------------------------------

  select(event) {
    this.choose(event.currentTarget);
  }

  choose(option) {
    if (this.isDisabled(option)) return;

    if (this.hasToggleAllTarget && option === this.toggleAllTarget) {
      this.toggleAll();
      return;
    }

    const input = this.inputOf(option);
    if (!input) return;

    if (this.multipleValue) {
      input.checked = !input.checked;
    } else {
      this.itemTargets.forEach((item) => {
        const other = this.inputOf(item);
        if (other && other !== input) other.checked = false;
      });
      input.checked = true;
    }
    this.notify(input);
    this.syncSelection();

    if (this.multipleValue) {
      if (this.hasChipsTarget) {
        this.inputTarget.value = "";
        this.applyFilter("");
      }
    } else {
      this.hide({ restoreFocus: true });
    }
  }

  toggleAll() {
    const inputs = this.itemTargets.map((item) => this.inputOf(item)).filter((input) => input && !input.disabled);
    const check = !inputs.every((input) => input.checked);
    inputs.forEach((input) => {
      if (input.checked === check) return;
      input.checked = check;
      this.notify(input);
    });
    this.syncSelection();
  }

  clear(event) {
    event?.preventDefault();
    this.clearSelection();
    if (this.hasInputTarget) {
      this.inputTarget.value = "";
      this.inputTarget.focus();
    }
    if (this.isOpen) this.applyFilter("");
  }

  // Disabled items keep their selection: their chips can't be removed either.
  clearSelection() {
    this.itemTargets.forEach((item) => {
      const input = this.inputOf(item);
      if (!input?.checked || this.isDisabled(item) || input.disabled) return;
      input.checked = false;
      this.notify(input);
    });
    this.syncSelection();
  }

  removeChip(event) {
    event.preventDefault();
    event.stopPropagation();
    const chip = event.currentTarget.closest("[data-slot=combobox-chip]");
    if (chip?.hasAttribute("data-summary")) {
      this.clearSelection();
      if (this.hasInputTarget) this.inputTarget.focus();
      return;
    }
    const value = chip?.dataset.value;
    const item = this.itemTargets.find((candidate) => candidate.dataset.value === value);
    const input = item && this.inputOf(item);
    if (!input) return;
    input.checked = false;
    this.notify(input);
    this.syncSelection();
    // The clicked button left the DOM with its chip; keep typing in the input.
    if (this.hasInputTarget) this.inputTarget.focus();
  }

  removeLastSelected() {
    // The summary chip stands for the whole selection, so it goes as one.
    if (this.chipsSummarized) {
      this.clearSelection();
      return;
    }
    const input = this.selectedItems.filter((item) => !this.isDisabled(item)).map((item) => this.inputOf(item)).at(-1);
    if (!input || input.disabled) return;
    input.checked = false;
    this.notify(input);
    this.syncSelection();
  }

  // Listeners on the native inputs (FormField, CheckboxGroup) see the change.
  notify(input) {
    input.dispatchEvent(new Event("input", { bubbles: true }));
    input.dispatchEvent(new Event("change", { bubbles: true }));
  }

  syncSelection() {
    const selected = this.selectedItems;

    this.itemTargets.forEach((item) => {
      item.setAttribute("aria-selected", selected.includes(item) ? "true" : "false");
    });
    if (this.hasToggleAllTarget) {
      const enabled = this.itemTargets.filter((item) => !this.isDisabled(item));
      const all = enabled.length > 0 && enabled.every((item) => selected.includes(item));
      this.toggleAllTarget.setAttribute("aria-selected", all ? "true" : "false");
    }
    if (this.hasValueTarget) this.renderValue(selected);
    if (this.hasClearTarget) this.clearTarget.hidden = selected.length === 0;
    if (this.hasChipsTarget) this.renderChips(selected);
  }

  renderValue(selected) {
    const value = this.valueTarget;
    if (selected.length === 0) {
      value.textContent = value.dataset.placeholderText || "";
      value.setAttribute("data-placeholder", "");
      return;
    }
    value.removeAttribute("data-placeholder");
    value.textContent =
      this.termValue && selected.length > 1
        ? `${selected.length} ${this.termValue}`
        : selected.map((item) => this.textOf(item)).join(", ");
  }

  renderChips(selected) {
    this.chipsTarget.querySelectorAll(":scope > [data-slot=combobox-chip]").forEach((chip) => chip.remove());
    if (!this.hasChipTemplateTarget) return;

    const before = this.hasInputTarget && this.chipsTarget.contains(this.inputTarget) ? this.inputTarget : null;
    if (this.chipsSummarized) {
      const chip = this.chipTemplateTarget.content.firstElementChild.cloneNode(true);
      chip.setAttribute("data-summary", "");
      const text = chip.querySelector("[data-text]") || chip;
      text.textContent = `${selected.length} ${this.termValue || "selected"}`;
      chip.querySelector("[data-slot=combobox-chip-remove]")?.setAttribute("aria-label", "Clear selection");
      if (this.disabled) chip.querySelector("button")?.setAttribute("disabled", "");
      this.chipsTarget.insertBefore(chip, before);
      return;
    }
    selected.forEach((item) => {
      const chip = this.chipTemplateTarget.content.firstElementChild.cloneNode(true);
      chip.dataset.value = item.dataset.value;
      const text = chip.querySelector("[data-text]") || chip;
      text.textContent = this.textOf(item);
      chip.querySelector("[data-slot=combobox-chip-remove]")?.setAttribute("aria-label", `Remove ${this.textOf(item)}`);
      if (this.isDisabled(item) || this.disabled) chip.querySelector("button")?.setAttribute("disabled", "");
      this.chipsTarget.insertBefore(chip, before);
    });
  }

  // --- Helpers --------------------------------------------------------------

  // ComboboxChips(max:): past the cap, one "<count> <term>" chip replaces them.
  get chipsSummarized() {
    if (!this.hasChipsTarget) return false;
    const max = parseInt(this.chipsTarget.dataset.max, 10);
    return Number.isInteger(max) && max >= 0 && this.selectedItems.length > max;
  }

  get visibleOptions() {
    const options = [...(this.hasToggleAllTarget ? [this.toggleAllTarget] : []), ...this.itemTargets];
    return options
      .filter((option) => !option.hidden && !this.isDisabled(option))
      .sort((a, b) => (a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1));
  }

  get selectedItems() {
    return this.itemTargets.filter((item) => this.inputOf(item)?.checked);
  }

  get selectedText() {
    return this.selectedItems.map((item) => this.textOf(item)).join(", ");
  }

  inputOf(item) {
    return item.querySelector("input[type=radio], input[type=checkbox]");
  }

  textOf(item) {
    return item.dataset.text || item.textContent.trim();
  }

  isDisabled(option) {
    return option.hasAttribute("data-disabled") || option.getAttribute("aria-disabled") === "true";
  }

  assignOptionIds() {
    const prefix = (this.hasListTarget && this.listTarget.id) || this.element.id || "combobox";
    const options = [...(this.hasToggleAllTarget ? [this.toggleAllTarget] : []), ...this.itemTargets];
    let next = 0;
    options.forEach((option) => {
      if (option.id) return;
      while (document.getElementById(`${prefix}-option-${next}`)) next++;
      option.id = `${prefix}-option-${next}`;
    });
  }

  // --- Positioning ----------------------------------------------------------

  position() {
    this.stopAutoUpdate();
    const anchor = this.anchor;
    const content = this.contentTarget;
    const side = content.dataset.preferredSide || "bottom";
    const align = content.dataset.align || "start";
    const placement = align === "center" ? side : `${side}-${align}`;
    const sideOffset = Number(content.dataset.sideOffset ?? 6);
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
            apply({ availableWidth, availableHeight, rects }) {
              content.style.setProperty("--anchor-width", `${rects.reference.width}px`);
              content.style.setProperty("--available-width", `${availableWidth}px`);
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
    const cross = { start: side === "top" || side === "bottom" ? "left" : "top", end: side === "top" || side === "bottom" ? "right" : "bottom" }[align] || "center";
    return side === "top" || side === "bottom" ? `${cross} ${opposite}` : `${opposite} ${cross}`;
  }

  stopAutoUpdate() {
    this.cleanup?.();
    this.cleanup = null;
  }

  // --- Exit animation (same block as the other overlay controllers) --------

  exitAnimationNames = new WeakMap();

  hideAfterExitAnimation(animated) {
    const exitAnimations = animated.getAnimations().filter((animation) => animation instanceof CSSAnimation);
    if (exitAnimations.length === 0) {
      this.settleExit(animated);
      return;
    }
    this.exitAnimationNames.set(animated, exitAnimations.map((animation) => animation.animationName));
    animated.addEventListener("animationend", this.handleExitAnimationEnd);
    animated.addEventListener("animationcancel", this.handleExitAnimationEnd);
  }

  handleExitAnimationEnd = (event) => {
    if (event.target !== event.currentTarget) return;
    if (!this.exitAnimationNames.get(event.currentTarget)?.includes(event.animationName)) return;
    this.settleExit(event.currentTarget);
  };

  settleExit(animated) {
    animated.removeEventListener("animationend", this.handleExitAnimationEnd);
    animated.removeEventListener("animationcancel", this.handleExitAnimationEnd);
    // Reopened mid-exit: leave it showing.
    if (!animated.hasAttribute("data-closed")) return;
    if (animated.matches(":popover-open")) animated.hidePopover();
  }
}
