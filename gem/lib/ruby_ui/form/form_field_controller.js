import { Controller } from "@hotwired/stimulus";

let fieldCount = 0;

export default class extends Controller {
  static targets = ["input", "error", "hint"];
  static values = { shouldValidate: false };

  connect() {
    this.#describeInputs();

    // FormFieldError hides itself through `empty:hidden`, so its text is the
    // only state: whitespace-only content is cleared to keep `:empty` true.
    if (this.hasErrorTarget) {
      if (this.errorTarget.textContent.trim()) {
        this.shouldValidateValue = true;
        this.#setInvalid(this.inputTargets);
      } else {
        this.errorTarget.textContent = "";
      }
    }
  }

  onInvalid(event) {
    // Without a FormFieldError, the browser's own bubble shows the message.
    if (this.hasErrorTarget) event.preventDefault();

    this.shouldValidateValue = true;
    this.#setErrorMessage();
  }

  onInput() {
    this.#setErrorMessage();
  }

  onChange() {
    this.#setErrorMessage();
  }

  #setErrorMessage() {
    if (!this.shouldValidateValue) return;

    // A field with several controls (e.g. required checkboxes) is invalid
    // when any of them is; the message comes from the first invalid one.
    const invalidInputs = this.inputTargets.filter((input) => !input.validity.valid);
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = invalidInputs.length
        ? this.#getValidationMessage(invalidInputs[0])
        : "";
    }
    this.#setInvalid(invalidInputs);
  }

  // Mirrors shadcn's Field pattern: data-invalid on the field (label turns
  // destructive) and aria-invalid on the invalid controls.
  #setInvalid(invalidInputs) {
    if (invalidInputs.length) {
      this.element.dataset.invalid = "true";
    } else {
      delete this.element.dataset.invalid;
    }

    this.inputTargets.forEach((input) => {
      if (invalidInputs.includes(input)) {
        input.setAttribute("aria-invalid", "true");
      } else {
        input.removeAttribute("aria-invalid");
      }
    });
  }

  // Points every control at the hint and error, keeping ids the author set.
  #describeInputs() {
    const ids = [
      ...this.hintTargets.map((hint) => [hint, "hint"]),
      ...(this.hasErrorTarget ? [[this.errorTarget, "error"]] : []),
    ].map(([element, part]) => this.#ensureId(element, part));
    if (ids.length === 0) return;

    this.inputTargets.forEach((input) => {
      const current = (input.getAttribute("aria-describedby") || "")
        .split(/\s+/)
        .filter(Boolean);
      const merged = [...new Set([...current, ...ids])];
      input.setAttribute("aria-describedby", merged.join(" "));
    });
  }

  #ensureId(element, part) {
    if (!element.id) {
      fieldCount += 1;
      element.id = `ruby-ui-form-field-${fieldCount}-${part}`;
    }
    return element.id;
  }

  #getValidationMessage(input) {
    let errorMessage;

    const { validity, dataset, validationMessage } = input;

    if (validity.tooLong) errorMessage = dataset.tooLong;
    if (validity.tooShort) errorMessage = dataset.tooShort;
    if (validity.badInput) errorMessage = dataset.badInput;
    if (validity.typeMismatch) errorMessage = dataset.typeMismatch;
    if (validity.stepMismatch) errorMessage = dataset.stepMismatch;
    if (validity.valueMissing) errorMessage = dataset.valueMissing;
    if (validity.rangeOverflow) errorMessage = dataset.rangeOverflow;
    if (validity.rangeUnderflow) errorMessage = dataset.rangeUnderflow;
    if (validity.patternMismatch) errorMessage = dataset.patternMismatch;

    return errorMessage || validationMessage;
  }
}
