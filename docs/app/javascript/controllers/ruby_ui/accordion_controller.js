import { Controller } from "@hotwired/stimulus";
import { animate } from "motion";

// Connects to data-controller="ruby-ui--accordion"
export default class extends Controller {
  static targets = ["icon", "content"];
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
      default: "ease-in-out", // Default animation easing
    },
    rotateIcon: {
      type: Number,
      default: 180, // Default icon rotation (in degrees)
    },
  };

  connect() {
    // Set the initial state of the accordion
    let originalAnimationDuration = this.animationDurationValue;
    this.animationDurationValue = 0;
    this.openValue ? this.open() : this.close();
    this.animationDurationValue = originalAnimationDuration;
  }

  // Toggle the 'open' value
  toggle() {
    this.openValue = !this.openValue;
  }

  // Handle changes in the 'open' value
  openValueChanged(isOpen, wasOpen) {
    if (isOpen) {
      this.open();
    } else {
      this.close();
    }
  }

  // Open the accordion content
  open() {
    if (this.hasContentTarget) {
      this.revealContent();
      this.hasIconTarget && this.rotateIcon();
      this.openValue = true;
    }
  }

  // Close the accordion content
  close() {
    if (this.hasContentTarget) {
      this.hideContent();
      this.hasIconTarget && this.rotateIcon();
      this.openValue = false;
    }
  }

  // Reveal the accordion content with animation
  revealContent() {
    const contentHeight = this.contentTarget.scrollHeight;
    animate(
      this.contentTarget,
      { height: `${contentHeight}px` },
      {
        duration: this.animationDurationValue,
        easing: this.animationEasingValue,
      },
    );
  }

  // Hide the accordion content with animation
  hideContent() {
    animate(
      this.contentTarget,
      { height: 0 },
      {
        duration: this.animationDurationValue,
        easing: this.animationEasingValue,
      },
    );
  }

  // Rotate the accordion icon 180deg using animate function
  rotateIcon() {
    animate(this.iconTarget, {
      rotate: `${this.openValue ? this.rotateIconValue : 0}deg`,
    });
  }
}
