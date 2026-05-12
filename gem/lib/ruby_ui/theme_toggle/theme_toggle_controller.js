import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--theme-toggle"
// Sits on the same wrapper as ruby-ui--toggle. Listens for the toggle's
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
    // Flip the sibling Toggle controller's pressed value; it will propagate
    // aria-pressed / data-state to the button target.
    const dark = theme === "dark"
    this.element.setAttribute("data-ruby-ui--toggle-pressed-value", dark ? "true" : "false")
  }
}
