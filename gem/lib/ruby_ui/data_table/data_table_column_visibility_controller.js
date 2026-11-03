// app/javascript/controllers/ruby_ui/data_table_column_visibility_controller.js
import { Controller } from "@hotwired/stimulus";

// Shows/hides [data-column] cells from the DropdownMenuCheckboxItems of
// DataTableColumnToggle (data-column-key + aria-checked).
export default class extends Controller {
  connect() {
    this.element
      .querySelectorAll("[data-column-key]")
      .forEach((item) => this._apply(item.dataset.columnKey, item.getAttribute("aria-checked") !== "false"));
  }

  // ruby-ui--dropdown-menu:change, fired by the checkbox item that changed.
  toggle(event) {
    const key = event.target.dataset.columnKey;
    if (key) this._apply(key, event.detail.checked);
  }

  _apply(key, visible) {
    const root = this.element.closest('[data-controller~="ruby-ui--data-table"]');
    if (!root) return;
    root
      .querySelectorAll(`[data-column="${key}"]`)
      .forEach((el) => el.classList.toggle("hidden", !visible));
  }
}
