// app/javascript/controllers/ruby_ui/data_table_column_visibility_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element
      .querySelectorAll("input[type=checkbox][data-column-key]")
      .forEach((checkbox) =>
        this._apply(checkbox.dataset.columnKey, checkbox.checked)
      );
  }

  toggle(event) {
    this._apply(event.target.dataset.columnKey, event.target.checked);
  }

  _apply(key, visible) {
    const root = this.element.closest('[data-controller~="ruby-ui--data-table"]');
    if (!root) return;
    root
      .querySelectorAll(`[data-column="${key}"]`)
      .forEach((el) => el.classList.toggle("hidden", !visible));
  }
}
