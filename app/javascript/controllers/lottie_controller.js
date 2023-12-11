import { Controller } from "@hotwired/stimulus"
import lottie from 'lottie-web'

// Connects to data-controller="lottie"
export default class extends Controller {
  static values = { 
    path: String,
    options: {
      type: Object,
      default: {}
    },
    delay: {
      type: Number,
      default: 0
    }
  }

  connect() {
    this.setupAnimationOptions()
    this.initializeLottieAnimation()
  }

  disconnect() {
    this.removeAnimationCompleteListener()
    this.destroyLottieAnimation()
  }

  setupAnimationOptions() {
    this.optionsValue = {
      renderer: 'svg',
      loop: true,
      autoplay: false,
      ...this.optionsValue,
    }
  }

  initializeLottieAnimation() {
    this.lottie = lottie.loadAnimation({
      container: this.element,
      path: this.pathValue,
      ...this.optionsValue
    })

    this.addAnimationCompleteListener()
    this.playAnimation()
  }

  playAnimation() {
    setTimeout(() => {
      this.lottie.play()
    }, this.delayValue);
  }
    

  addAnimationCompleteListener() {
    this.onComplete = () => {
      this.playAnimation()
    };

    this.lottie.addEventListener('complete', this.onComplete);
  }

  removeAnimationCompleteListener() {
    this.lottie.removeEventListener('complete', this.onComplete);
  }

  destroyLottieAnimation() {
    this.lottie.destroy()
  }
}