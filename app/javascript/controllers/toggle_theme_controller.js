import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-theme"
export default class extends Controller {
  initialize() {
    this.setTheme()
  }

  setTheme() {
    // On page load or when changing themes, best to add inline in `head` to avoid FOUC
    if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  setLightTheme() {
    // Whenever the user explicitly chooses light mode
    localStorage.theme = 'light'
    this.setTheme()
  }

  setDarkTheme() {
    // Whenever the user explicitly chooses dark mode
    localStorage.theme = 'dark'
    this.setTheme()
  }
}
