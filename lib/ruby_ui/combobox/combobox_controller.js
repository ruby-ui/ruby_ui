import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset } from "@floating-ui/dom";

export const POPOVER_OPENED = "ruby_ui--combobox#popoverOpened";

export default class extends Controller {
  static targets = [
    "input",
    "trigger",
    "value",
    "content",
    "search",
    "list",
    "item",
  ];
  static values = { open: Boolean };
  static outlets = ["ruby_ui--combobox-item", "ruby_ui--combobox-content"];

  constructor(...args) {
    super(...args);
    this.cleanup;
  }

  connect() {
    this.#setFloatingElement();
    this.#generateItemsIds();
  }

  disconnect() {
    this.cleanup();
  }

  onTriggerClick(event) {
    event.preventDefault();

    if (this.openValue) {
      this.#closeContent();
    } else {
      this.#openContent();
    }
  }

  onItemSelected(event) {
    event.preventDefault();

    this.#setValueDispatchEventAndCloseContent(event.target);
  }

  onKeyEnter(event) {
    event.preventDefault();

    const currentItem = this.itemTargets.find(
      (item) => item.getAttribute("aria-current") === "true",
    );

    if (!currentItem) this.#closeContent();

    this.#setValueDispatchEventAndCloseContent(currentItem);
  }

  onSearchInput(event) {
    this.ruby_uiComboboxContentOutlet.handleSearchInput(event.target.value);
    this.#findAndSetCurrentAndActiveDescendant();
  }

  onClickOutside(event) {
    if (!this.openValue) return;
    if (this.element.contains(event.target)) return;

    event.preventDefault();
    this.#closeContent();
  }

  onEscKey(event) {
    event.preventDefault();

    this.#closeContent();
  }

  onKeyDown(event) {
    event.preventDefault();

    const currentIndex = this.itemTargets.findIndex(
      (item) => item.getAttribute("aria-current") === "true",
    );

    if (currentIndex + 1 < this.itemTargets.length) {
      this.itemTargets[currentIndex].removeAttribute("aria-current");

      const currentItem = this.itemTargets[currentIndex + 1];
      this.#setCurrentAndActiveDescendant(currentItem);
    }
  }

  onKeyUp(event) {
    event.preventDefault();
    const currentIndex = this.itemTargets.findIndex(
      (item) => item.getAttribute("aria-current") === "true",
    );

    if (currentIndex > 0) {
      this.itemTargets[currentIndex].removeAttribute("aria-current");

      const currentItem = this.itemTargets[currentIndex - 1];
      this.#setCurrentAndActiveDescendant(currentItem);
    }
  }

  #closeContent() {
    this.openValue = false;
    this.contentTarget.classList.add("hidden");
    this.triggerTarget.setAttribute("aria-expanded", false);
    this.triggerTarget.setAttribute("aria-activedescendant", true);
    this.itemTargets.forEach((item) => item.removeAttribute("aria-current"));

    this.triggerTarget.focus({ preventScroll: true });
  }

  #openContent() {
    this.openValue = true;
    this.contentTarget.classList.remove("hidden");
    this.triggerTarget.setAttribute("aria-expanded", true);

    this.#findAndSetCurrentAndActiveDescendant();
    this.searchTarget.focus({ preventScroll: true });
  }

  #findAndSetCurrentAndActiveDescendant() {
    const selectedItem = this.itemTargets.find(
      (item) => item.getAttribute("aria-selected") === "true",
    );

    if (selectedItem) {
      this.#setCurrentAndActiveDescendant(selectedItem);
      return;
    }

    const selectedVisible = this.itemTargets.find(
      (item) => !item.classList.contains("hidden"),
    );
    this.#setCurrentAndActiveDescendant(selectedVisible);
  }

  #setCurrentAndActiveDescendant(item) {
    if (!item) return;

    item.setAttribute("aria-current", "true");
    this.triggerTarget.setAttribute(
      "aria-activedescendant",
      item.getAttribute("id"),
    );
  }

  #setValueDispatchEventAndCloseContent(item) {
    const oldValue = this.inputTarget.value;
    const newValue = item.dataset.value;

    this.ruby_uiComboboxItemOutlets.forEach((item) =>
      item.handleItemSelected(newValue),
    );

    this.inputTarget.value = item.dataset.value;
    this.valueTarget.innerText = item.innerText;

    this.#dispatchOnChange(oldValue, newValue);
    this.#closeContent();
  }

  #dispatchOnChange(oldValue, newValue) {
    if (oldValue === newValue) return;

    const event = new InputEvent("change", {
      bubbles: true,
      cancelable: true,
    });

    this.inputTarget.dispatchEvent(event);
  }

  #generateItemsIds() {
    const listId = this.listTarget.getAttribute("id");
    this.triggerTarget.setAttribute("aria-controls", listId);

    this.itemTargets.forEach((item, index) => {
      item.id = `${listId}-${index}`;
    });
  }

  #setFloatingElement() {
    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      computePosition(this.triggerTarget, this.contentTarget, {
        middleware: [offset(4)],
      }).then(({ x, y }) => {
        Object.assign(this.contentTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
      });
    });
  }
}
