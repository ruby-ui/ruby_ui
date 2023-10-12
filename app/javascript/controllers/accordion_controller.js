import { Controller } from "@hotwired/stimulus"
import { animate } from "motion"

// Define a flag to check if the initial state is set
let initialStateSet = false

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = ['icon', 'content']
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
      this.hasIconTarget && this.rotateIcon()
      this.openValue = true
    }
  }

  // Close the accordion content
  close() {
    if (this.hasContentTarget) {
      this.hideContent()
      this.hasIconTarget && this.rotateIcon()
      this.openValue = false
    }
  }

  // Reveal the accordion content with animation
  revealContent() {
    const contentHeight = this.contentTarget.scrollHeight;
    const duration = initialStateSet ? this.animationDurationValue : 0
    animate(this.contentTarget, { height: `${contentHeight}px` }, { duration: duration, easing: this.animationEasingValue })
    initialStateSet = true
  }

  // Hide the accordion content with animation
  hideContent() {
    const duration = initialStateSet ? this.animationDurationValue : 0
    animate(this.contentTarget, { height: 0 }, { duration: duration, easing: this.animationEasingValue })
    initialStateSet = true
  }

  // Rotate the accordion icon 180deg using animate function
  rotateIcon() {
    animate(this.iconTarget, { rotate: `${this.openValue ? 180 : 0}deg` })
  }
}