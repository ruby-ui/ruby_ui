import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "error"];
  static values = { shouldValidate: false };

  connect() {
    if (this.hasErrorTarget) {
      if (this.errorTarget.textContent) {
        this.shouldValidateValue = true;
      } else {
        this.errorTarget.classList.add("hidden");
      }
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
    let errorMessage;

    const { validity, dataset, validationMessage } = this.inputTarget;

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
