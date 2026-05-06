// app/javascript/controllers/ruby_ui/data_table_column_visibility_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  toggle(event) {
    const key = event.target.dataset.columnKey;
    const visible = event.target.checked;
    const root = this.element.closest('[data-controller~="ruby-ui--data-table"]');
    if (!root) return;
    root
      .querySelectorAll(`[data-column="${key}"]`)
      .forEach((el) => el.classList.toggle("hidden", !visible));
  }
}
