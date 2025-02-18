import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar-menu"
export default class extends Controller {
  connect() {
    window.addEventListener("turbo:before-cache", () => {
      localStorage.setItem("menuScrollPositon", this.element.scrollTop);
    });

    window.addEventListener("turbo:before-render", () => {
      this.element.scrollTop = localStorage.getItem("menuScrollPositon") || 0;
    });
    window.addEventListener("turbo:render", () => {
      this.element.scrollTop = localStorage.getItem("menuScrollPositon") || 0;
    });
  }
}
