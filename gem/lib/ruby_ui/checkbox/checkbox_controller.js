import { Controller } from "@hotwired/stimulus";

// Wired by RubyUI::Checkbox only when indeterminate: or readonly: is set.
export default class extends Controller {
  static values = { indeterminate: Boolean, readonly: Boolean };

  // indeterminate has no HTML attribute: it is a property of the input.
  indeterminateValueChanged(value) {
    this.element.indeterminate = value;
  }

  // Click covers mouse, Space and clicks on an associated <label>.
  guard(event) {
    if (this.readonlyValue) event.preventDefault();
  }

  // The browser clears indeterminate on toggle; keep the value in step so a
  // reconnect doesn't bring it back.
  sync() {
    if (this.indeterminateValue && !this.element.indeterminate) this.indeterminateValue = false;
  }
}
