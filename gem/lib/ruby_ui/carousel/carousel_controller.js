import { Controller } from "@hotwired/stimulus";
import EmblaCarousel from 'embla-carousel'

const DEFAULT_OPTIONS = {
  loop: true
}

export default class extends Controller {
  static values = {
    options: {
      type: Object,
      default: {},
    }
  }
  static targets = ["viewport", "nextButton", "prevButton"]

  connect() {
    this.initCarousel(this.#mergedOptions)
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

  #toggleButtonsDisabledState(buttons, isDisabled) {
    buttons.forEach((button) => button.disabled = isDisabled)
  }

  get #mergedOptions() {
    return {
      ...DEFAULT_OPTIONS,
      ...this.optionsValue
    }
  }
}
