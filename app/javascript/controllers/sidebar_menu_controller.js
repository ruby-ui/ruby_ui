import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar-menu"
export default class extends Controller {
  connect() {
    window.addEventListener("turbo:before-visit", () => {
      localStorage.setItem("menuScrollPositon", this.element.scrollTop);
    });

    window.addEventListener("turbo:load", () => {
      this.element.scrollTop = localStorage.getItem("menuScrollPositon") || 0;
    });
  }
}
