import { Controller } from "@hotwired/stimulus";
import EmblaCarousel from 'embla-carousel'

export default class extends Controller {
  static values = {
    options: {
      type: Object,
      default: {},
    }
  }
  static targets = ["viewport", "nextButton", "prevButton"]

  connect() {
    this.initCarousel(this.optionsValue)
  }

  disconnect() {
    this.destroyCarousel()
  }

  initCarousel(options, plugins = []) {
    this.carousel = EmblaCarousel(this.viewportTarget, options, plugins)

    this.carousel.on("init", this.#updateControls.bind(this))
    this.carousel.on("reInit", this.#updateControls.bind(this))
    this.carousel.on("select", this.#updateControls.bind(this))
  }

  destroyCarousel() {
    this.carousel.destroy()
  }

  scrollNext() {
    this.carousel.scrollNext()
  }

  scrollPrev() {
    this.carousel.scrollPrev()
  }

  #updateControls() {
    this.#toggleButtonsDisabledState(this.nextButtonTargets, !this.carousel.canScrollNext())
    this.#toggleButtonsDisabledState(this.prevButtonTargets, !this.carousel.canScrollPrev())
  }

  // Button renders data-disabled next to disabled; keep both in step.
  #toggleButtonsDisabledState(buttons, isDisabled) {
    buttons.forEach((button) => {
      button.disabled = isDisabled
      button.toggleAttribute("data-disabled", isDisabled)
    })
  }
}
