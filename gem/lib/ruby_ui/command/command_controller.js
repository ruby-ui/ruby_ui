import { Controller } from "@hotwired/stimulus";
import Fuse from "fuse.js";

// Prefix for generated ids, unique per page (ruby-ui-command-1-list, …).
let commandCount = 0;

// Connects to data-controller="ruby-ui--command"
//
// Follows the APG combobox pattern with a listbox popup: focus stays in the
// input, the active option is announced through aria-activedescendant and
// marked aria-selected="true" + data-selected. The first visible option is
// active on connect and after every search; ArrowUp/ArrowDown move it (wrapping
// only with loop: true), Home/End jump to the ends, the pointer moves it too,
// and Enter or a click selects it.
export default class extends Controller {
  static targets = ["input", "list", "item", "group", "heading", "separator", "empty"];
  static values = { loop: { type: Boolean, default: false } };

  connect() {
    this.active = null;
    this.searchIndex = null;
    this.wireAria();
    this.dialog = this.element.closest("dialog");
    this.dialog?.addEventListener("close", this.reset);
    // Reconnected (Turbo cache, morph): drop the active marks left in the DOM
    // and filter by what the input still holds.
    this.itemTargets.forEach((item) => this.markActive(item, false));
    this.applyQuery(this.currentQuery(), { scroll: false });
    this.ready = true;
  }

  disconnect() {
    this.ready = false;
    this.dialog?.removeEventListener("close", this.reset);
    this.dialog = null;
    this.active = null;
  }

  // Items added or removed later (e.g. a Turbo Stream) get an id and go through
  // the current search, once per batch of changes.
  itemTargetConnected(item) {
    this.searchIndex = null;
    this.ensureId(item, this.nextOptionId());
    this.scheduleRefresh();
  }

  itemTargetDisconnected(item) {
    this.searchIndex = null;
    if (item === this.active) this.active = null;
    this.scheduleRefresh();
  }

  scheduleRefresh() {
    if (!this.ready || this.refreshQueued) return;
    this.refreshQueued = true;
    queueMicrotask(() => {
      this.refreshQueued = false;
      if (this.ready) this.applyQuery(this.currentQuery(), { scroll: false, keepActive: true });
    });
  }

  // A closed dialog opens again with an empty search and the first item active.
  reset = () => {
    if (!this.hasInputTarget) return;
    this.inputTarget.value = "";
    this.applyQuery("", { scroll: false });
    if (this.hasListTarget) this.listTarget.scrollTop = 0;
  };

  currentQuery() {
    return this.hasInputTarget ? this.inputTarget.value.trim() : "";
  }

  focusInput() {
    if (this.hasInputTarget) this.inputTarget.focus();
  }

  filter() {
    this.applyQuery(this.currentQuery());
  }

  // Shows the items matching query and makes the first selectable one active
  // (or keeps the active one when keepActive and it is still shown). Scrolls
  // the list to it only for user actions: scrolling on connect could move the
  // whole page to a Command below the fold.
  applyQuery(query, { scroll = true, keepActive = false } = {}) {
    if (query.length === 0) {
      this.itemTargets.forEach((item) => (item.hidden = false));
    } else {
      const matches = new Set(this.index().search(query).map((result) => result.item.element));
      this.itemTargets.forEach((item) => (item.hidden = !matches.has(item)));
    }

    this.groupTargets.forEach((group) => {
      group.hidden = !this.itemTargets.some((item) => !item.hidden && group.contains(item));
    });
    // Separators only make sense between full groups.
    this.separatorTargets.forEach((separator) => (separator.hidden = query.length > 0));
    const visible = this.visibleItems();
    this.emptyTargets.forEach((empty) => (empty.hidden = visible.length > 0));

    const selectable = visible.filter((item) => !this.isDisabled(item));
    const next = keepActive && selectable.includes(this.active) ? this.active : selectable[0] || null;
    this.activate(next, { scroll });
  }

  index() {
    if (!this.searchIndex) {
      const entries = this.itemTargets.map((element) => ({
        value: this.valueOf(element),
        keywords: element.dataset.keywords || "",
        element,
      }));
      this.searchIndex = new Fuse(entries, { keys: ["value", "keywords"], threshold: 0.2, ignoreLocation: true });
    }
    return this.searchIndex;
  }

  inputKeydown(event) {
    if (event.isComposing) return;

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.move(1);
        break;
      case "ArrowUp":
        event.preventDefault();
        this.move(-1);
        break;
      case "Home":
      case "End": {
        event.preventDefault();
        const items = this.selectableItems();
        this.activate(event.key === "Home" ? items[0] : items[items.length - 1]);
        break;
      }
      case "Enter":
        if (!this.active) return;
        event.preventDefault();
        this.select(this.active, event);
        break;
    }
  }

  move(step) {
    const items = this.selectableItems();
    if (items.length === 0) return;

    const index = items.indexOf(this.active);
    let next = index === -1 ? (step > 0 ? 0 : items.length - 1) : index + step;
    if (next < 0 || next >= items.length) {
      if (!this.loopValue) return;
      next = (next + items.length) % items.length;
    }
    this.activate(items[next]);
  }

  itemPointermove(event) {
    const item = event.currentTarget;
    if (item !== this.active && !this.isDisabled(item)) this.activate(item, { scroll: false });
  }

  itemClick(event) {
    const item = event.currentTarget;
    if (this.isDisabled(item)) return;
    // The click moved focus to the list (tabindex=-1); the keyboard handlers
    // live on the input, so bring it back.
    this.focusInput();
    this.activate(item, { scroll: false });
    this.select(item, event);
  }

  // Dispatches ruby-ui--command:select (cancelable) and, unless prevented,
  // follows the item's href. ⌘/Ctrl opens the href in a new tab.
  select(item, event) {
    const value = this.valueOf(item);
    const href = item.dataset.href;
    const selectEvent = this.dispatch("select", { detail: { value, href, item }, cancelable: true });
    if (selectEvent.defaultPrevented || !href) return;

    if (event?.metaKey || event?.ctrlKey) {
      window.open(href, "_blank", "noopener");
    } else if (window.Turbo?.visit) {
      window.Turbo.visit(href);
    } else {
      window.location.assign(href);
    }
  }

  activate(item, { scroll = true } = {}) {
    if (this.active && this.active !== item) this.markActive(this.active, false);
    this.active = item;

    if (!item) {
      if (this.hasInputTarget) this.inputTarget.removeAttribute("aria-activedescendant");
      return;
    }

    this.markActive(item, true);
    if (this.hasInputTarget) this.inputTarget.setAttribute("aria-activedescendant", item.id);
    if (scroll) item.scrollIntoView({ block: "nearest" });
  }

  markActive(item, active) {
    item.setAttribute("aria-selected", String(active));
    if (active) item.setAttribute("data-selected", "true");
    else item.removeAttribute("data-selected");
  }

  visibleItems() {
    return this.itemTargets.filter((item) => !item.hidden);
  }

  selectableItems() {
    return this.visibleItems().filter((item) => !this.isDisabled(item));
  }

  isDisabled(item) {
    return item.dataset.disabled === "true";
  }

  valueOf(item) {
    return item.dataset.value || item.textContent.trim();
  }

  // Ties the input to the listbox, names each group after its heading and
  // gives every option an id for aria-activedescendant. Never overwrites ids or
  // ARIA the author already set.
  wireAria() {
    const prefix = this.idPrefix();

    if (this.hasListTarget) {
      const listId = this.ensureId(this.listTarget, `${prefix}-list`);
      if (this.hasInputTarget && !this.inputTarget.hasAttribute("aria-controls")) {
        this.inputTarget.setAttribute("aria-controls", listId);
      }
      if (!this.listTarget.hasAttribute("aria-label") && !this.listTarget.hasAttribute("aria-labelledby")) {
        this.listTarget.setAttribute("aria-label", "Suggestions");
      }
    }

    this.headingTargets.forEach((heading, index) => {
      const headingId = this.ensureId(heading, `${prefix}-group-${index}-heading`);
      const items = heading.parentElement?.querySelector(":scope > [role=group]");
      if (items && !items.hasAttribute("aria-labelledby")) items.setAttribute("aria-labelledby", headingId);
    });

    this.itemTargets.forEach((item) => this.ensureId(item, this.nextOptionId()));
  }

  idPrefix() {
    this.prefix ||= `ruby-ui-command-${++commandCount}`;
    return this.prefix;
  }

  nextOptionId() {
    this.optionCount = (this.optionCount || 0) + 1;
    return `${this.idPrefix()}-option-${this.optionCount - 1}`;
  }

  ensureId(element, id) {
    if (!element.id) element.id = id;
    return element.id;
  }
}
