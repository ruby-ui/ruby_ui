import { Controller } from "@hotwired/stimulus"
import { animate } from "motion"

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = ['content']
  static values = {
    open: {
      type: Boolean,
      default: false,
    },
    animationDuration: {
      type: Number,
      default: 0.15, // Default animation duration (in seconds)
    },
    animationEasing: {
      type: String,
      default: 'ease-in-out', // Default animation easing
    },
  }

  connect() {
    // Set the initial state of the accordion
    let originalAnimationDuration = this.animationDurationValue
    this.animationDurationValue = 0
    this.openValue ? this.open() : this.close()
    this.animationDurationValue = originalAnimationDuration
  }

  // Toggle the 'open' value
  toggle() {
    this.openValue = !this.openValue
  }

  // Handle changes in the 'open' value
  openValueChanged(isOpen, wasOpen) {
    if (isOpen) {
      this.open()
    } else {
      this.close()
    }
  }

  // Open the accordion content
  open() {
    if (this.hasContentTarget) {
      this.revealContent()
      this.openValue = true
    }
  }

  // Close the accordion content
  close() {
    if (this.hasContentTarget) {
      this.hideContent()
      this.openValue = false
    }
  }

  // Reveal the accordion content with animation
  revealContent() {
    const contentHeight = this.contentTarget.scrollHeight;
    animate(this.contentTarget, { height: `${contentHeight}px` }, { duration: this.animationDurationValue, easing: this.animationEasingValue })
  }

  // Hide the accordion content with animation
  hideContent() {
    animate(this.contentTarget, { height: 0 }, { duration: this.animationDurationValue, easing: this.animationEasingValue })
  }
}