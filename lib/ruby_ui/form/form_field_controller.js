import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"];
  static values = { shouldValidate: false }


  connect() {
    if (this.errorTarget.textContent) {
      this.shouldValidateValue = true;
    } else {
      this.errorTarget.classList.add("hidden");
    }
  }

  onInvalid(error) {
    error.preventDefault();

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

    if (this.inputTarget.validity.valid) {
      this.errorTarget.textContent = "";
      this.errorTarget.classList.add("hidden");
    } else {
      this.errorTarget.textContent = this.#getValidationMessage();
      this.errorTarget.classList.remove("hidden");
    }
  }

  #getValidationMessage() {
    const input = this.inputTarget;
    const defaultMessage = this.inputTarget.validationMessage;

    if (input.validity.valueMissing) {
      return input.dataset.valueMissing || defaultMessage;
    }

    if (input.validity.badInput) {
      return input.dataset.badInput || defaultMessage;
    }

    if (input.validity.patternMismatch) {
      return input.dataset.patternMismatch || defaultMessage;
    }

    if (input.validity.rangeOverflow) {
      return input.dataset.rangeOverflow || defaultMessage;
    }

    if (input.validity.rangeUnderflow) {
      return input.dataset.rangeUnderflow || defaultMessage;
    }

    if (input.validity.stepMismatch) {
      return input.dataset.stepMismatch || defaultMessage;
    }

    if (input.validity.tooLong) {
      return input.dataset.tooLong || defaultMessage;
    }

    if (input.validity.tooShort) {
      return input.dataset.tooShort || defaultMessage;
    }

    if (input.validity.typeMismatch) {
      return input.dataset.typeMismatch || defaultMessage;
    }

    return defaultMessage;
  }
}
