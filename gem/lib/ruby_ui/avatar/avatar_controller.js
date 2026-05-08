import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image", "fallback"];

  connect() {
    if (!this.hasImageTarget) {
      return;
    }

    if (this.imageTarget.complete && this.imageTarget.naturalWidth > 0) {
      this.showImage();
    } else {
      // Image not yet loaded (or failed): hide it so the fallback shows.
      // Image visibility is restored by the load/error handlers.
      this.showFallback();
    }
  }

  showImage() {
    this.imageTargets.forEach((image) => image.classList.remove("hidden"));
    this.fallbackTargets.forEach((fallback) =>
      fallback.classList.add("hidden"),
    );
  }

  showFallback() {
    this.imageTargets.forEach((image) => image.classList.add("hidden"));
    this.fallbackTargets.forEach((fallback) =>
      fallback.classList.remove("hidden"),
    );
  }
}
