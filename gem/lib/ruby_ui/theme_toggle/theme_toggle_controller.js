import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--theme-toggle"
// Expects to sit on the same element as ruby-ui--toggle and listen to its
// ruby-ui--toggle:change event. pressed = dark mode.
export default class extends Controller {
  connect() {
    this.applyTheme(this.currentTheme())
  }

  apply(event) {
    const pressed = event.detail?.pressed
    const theme = pressed ? "dark" : "light"
    localStorage.theme = theme
    this.applyTheme(theme)
  }

  currentTheme() {
    if (localStorage.theme === "dark") return "dark"
    if (localStorage.theme === "light") return "light"
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  applyTheme(theme) {
    const html = document.documentElement
    if (theme === "dark") {
      html.classList.add("dark")
      html.classList.remove("light")
    } else {
      html.classList.add("light")
      html.classList.remove("dark")
    }
    const dark = theme === "dark"
    this.element.setAttribute("aria-pressed", dark ? "true" : "false")
    this.element.dataset.state = dark ? "on" : "off"
    this.element.setAttribute("data-ruby-ui--toggle-pressed-value", dark ? "true" : "false")
  }
}
