import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "error"];
  static values = { shouldValidate: false };

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
    let errorMessage;

    const { validity, dataset } = this.inputTarget;

    const validations = [
      "tooLong",
      "badInput",
      "tooShort",
      "typeMismatch",
      "stepMismatch",
      "valueMissing",
      "rangeOverflow",
      "rangeUnderflow",
      "patternMismatch",
    ];

    validations.forEach((validation) => {
      if (validity[validation]) errorMessage = dataset[validation];
    });

    return errorMessage || this.inputTarget.validationMessage;
  }
}
