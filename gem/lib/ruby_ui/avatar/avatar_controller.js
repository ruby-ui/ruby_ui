import { Controller } from "@hotwired/stimulus";

// Tracks the image's loading status like Base UI's Avatar: the image shows
// once it has loaded, the fallback shows otherwise (no image, still loading,
// or failed), after the fallback's optional data-delay (ms).
//
// Every status change dispatches `ruby-ui--avatar:status` with
// `detail: { status }`, where status is "loading", "loaded" or "error"
// (Base UI's onLoadingStatusChange).
export default class extends Controller {
  static targets = ["image", "fallback"];

  connect() {
    this.status = null;
    this.fallbackReady = false;
    // A delayed fallback is rendered with the hidden attribute; from here on
    // the controller drives its visibility with the hidden class.
    this.fallbackTargets.forEach((fallback) => (fallback.hidden = false));
    this.startFallbackDelay();

    if (!this.hasImageTarget) {
      this.render();
      return;
    }

    const image = this.imageTarget;
    if (image.complete) {
      this.setStatus(image.naturalWidth > 0 ? "loaded" : "error");
    } else {
      this.setStatus("loading");
    }
  }

  disconnect() {
    clearTimeout(this.delayTimer);
    this.delayTimer = null;
  }

  // load->ruby-ui--avatar#showImage
  showImage() {
    this.setStatus("loaded");
  }

  // error->ruby-ui--avatar#showFallback
  showFallback() {
    this.setStatus("error");
  }

  setStatus(status) {
    if (status !== this.status) {
      this.status = status;
      this.dispatch("status", { detail: { status } });
    }
    this.render();
  }

  startFallbackDelay() {
    clearTimeout(this.delayTimer);
    const delay = this.hasFallbackTarget
      ? Number(this.fallbackTarget.dataset.delay) || 0
      : 0;

    if (delay <= 0) {
      this.fallbackReady = true;
      return;
    }

    this.delayTimer = setTimeout(() => {
      this.delayTimer = null;
      this.fallbackReady = true;
      this.render();
    }, delay);
  }

  render() {
    const loaded = this.status === "loaded";
    this.imageTargets.forEach((image) =>
      image.classList.toggle("hidden", !loaded),
    );
    this.fallbackTargets.forEach((fallback) =>
      fallback.classList.toggle("hidden", loaded || !this.fallbackReady),
    );
  }
}
