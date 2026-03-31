import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, flip } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--combobox"
export default class extends Controller {
  static values = {
    term: String
  }

  static targets = [
    "input",
    "toggleAll",
    "popover",
    "item",
    "emptyState",
    "searchInput",
    "trigger",
    "triggerContent",
    "badgeContainer",
    "clearButton",
    "badgeInput",
    "inputTrigger"
  ]

  selectedItemIndex = null

  connect() {
    this.updateTriggerContent()
    this.updateBadges()
    this.updateClearButton()
    this.updateInputTrigger()
  }

  disconnect() {
    if (this.cleanup) { this.cleanup() }
  }

  // Popover

  togglePopover(event) {
    event.preventDefault()

    if (this.triggerTarget.ariaExpanded === "true") {
      this.closePopover()
    } else {
      this.openPopover(event)
    }
  }

  openPopover(event) {
    if (event && event.type !== "focus") event.preventDefault()

    this.updatePopoverPosition()
    this.updatePopoverWidth()
    this.triggerTarget.ariaExpanded = "true"
    this.selectedItemIndex = null
    this.itemTargets.forEach(item => item.ariaCurrent = "false")
    this.popoverTarget.showPopover()

    if (this.hasBadgeInputTarget) {
      this.badgeInputTarget.value = ""
      this.applyFilter("")
    } else if (this.hasInputTriggerTarget) {
      this.applyFilter(this.inputTriggerTarget.value)
    }
  }

  closePopover() {
    this.triggerTarget.ariaExpanded = "false"
    this.popoverTarget.hidePopover()
  }

  handlePopoverToggle(event) {
    // Keep ariaExpanded in sync with the actual popover state
    this.triggerTarget.ariaExpanded = event.newState === 'open' ? 'true' : 'false'
  }

  updatePopoverPosition() {
    this.cleanup = autoUpdate(this.triggerTarget, this.popoverTarget, () => {
      computePosition(this.triggerTarget, this.popoverTarget, {
        placement: 'bottom-start',
        middleware: [offset(4), flip()],
      }).then(({ x, y }) => {
        Object.assign(this.popoverTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
      });
    });
  }

  updatePopoverWidth() {
    this.popoverTarget.style.width = `${this.triggerTarget.offsetWidth}px`
  }

  // Selection

  inputChanged(e) {
    this.updateTriggerContent()

    if (e.target.type == "radio") {
      this.closePopover()
      this.updateInputTrigger()
    }

    if (this.hasToggleAllTarget && !e.target.checked) {
      this.toggleAllTarget.checked = false
    }

    this.updateBadges()
    this.updateClearButton()
  }

  toggleAllItems() {
    const isChecked = this.toggleAllTarget.checked
    this.inputTargets.forEach(input => input.checked = isChecked)
    this.updateTriggerContent()
    this.updateBadges()
    this.updateClearButton()
  }

  clearAll(event) {
    if (event) event.preventDefault()

    this.inputTargets.forEach(input => input.checked = false)
    this.updateBadges()
    this.updateClearButton()
    this.updateTriggerContent()
    this.updateInputTrigger()
  }

  removeBadge(event) {
    event.preventDefault()
    event.stopPropagation()

    const value = event.currentTarget.closest('[data-value]').dataset.value
    const input = this.inputTargets.find(input => input.value === value)

    if (input) {
      input.checked = false
      input.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  // Display

  inputContent(input) {
    return input.dataset.text || input.parentElement.textContent
  }

  updateTriggerContent() {
    const checkedInputs = this.inputTargets.filter(input => input.checked)

    if (checkedInputs.length === 0) {
      this.triggerContentTarget.innerText = this.triggerTarget.dataset.placeholder
    } else if (this.termValue && checkedInputs.length > 1) {
      this.triggerContentTarget.innerText = `${checkedInputs.length} ${this.termValue}`
    } else {
      this.triggerContentTarget.innerText = checkedInputs.map((input) => this.inputContent(input)).join(", ")
    }
  }

  updateInputTrigger() {
    if (!this.hasInputTriggerTarget) return
    const checked = this.inputTargets.find(i => i.checked)
    this.inputTriggerTarget.value = checked ? this.inputContent(checked) : ""
  }

  // NOTE: badge HTML mirrors ComboboxBadge Ruby component. Update both if styles change.
  updateBadges() {
    if (!this.hasBadgeContainerTarget) return

    this.badgeContainerTarget.innerHTML = ""

    this.inputTargets.filter(input => input.checked).forEach(input => {
      const badge = document.createElement("span")
      badge.className = "inline-flex items-center gap-1 rounded-md border bg-secondary px-1.5 py-0.5 text-xs font-medium text-secondary-foreground"
      badge.dataset.value = input.value

      const label = document.createTextNode(this.inputContent(input))
      badge.appendChild(label)

      const btn = document.createElement("button")
      btn.type = "button"
      btn.dataset.action = "ruby-ui--combobox#removeBadge"
      btn.setAttribute("aria-label", "Remove")
      btn.className = "rounded-sm opacity-50 hover:opacity-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"

      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
      svg.setAttribute("xmlns", "http://www.w3.org/2000/svg")
      svg.setAttribute("width", "12")
      svg.setAttribute("height", "12")
      svg.setAttribute("viewBox", "0 0 24 24")
      svg.setAttribute("fill", "none")
      svg.setAttribute("stroke", "currentColor")
      svg.setAttribute("stroke-width", "2")
      svg.setAttribute("stroke-linecap", "round")
      svg.setAttribute("stroke-linejoin", "round")

      const path1 = document.createElementNS("http://www.w3.org/2000/svg", "path")
      path1.setAttribute("d", "M18 6 6 18")
      const path2 = document.createElementNS("http://www.w3.org/2000/svg", "path")
      path2.setAttribute("d", "m6 6 12 12")

      svg.appendChild(path1)
      svg.appendChild(path2)
      btn.appendChild(svg)
      badge.appendChild(btn)

      this.badgeContainerTarget.appendChild(badge)
    })
  }

  updateClearButton() {
    if (!this.hasClearButtonTarget) return

    const hasChecked = this.inputTargets.some(input => input.checked)
    this.clearButtonTarget.classList.toggle("hidden", !hasChecked)
  }

  // Filter

  filterItems(e) {
    if (["ArrowDown", "ArrowUp", "Tab", "Enter"].includes(e.key)) return

    const term = this.hasBadgeInputTarget
      ? this.badgeInputTarget.value
      : this.hasInputTriggerTarget
        ? this.inputTriggerTarget.value
        : this.searchInputTarget.value

    this.applyFilter(term)
  }

  applyFilter(term) {
    const filterTerm = term.toLowerCase()

    if (this.hasToggleAllTarget) {
      if (filterTerm) this.toggleAllTarget.parentElement.classList.add("hidden")
      else this.toggleAllTarget.parentElement.classList.remove("hidden")
    }

    let resultCount = 0
    this.selectedItemIndex = null

    this.inputTargets.forEach((input) => {
      const text = this.inputContent(input).toLowerCase()
      if (text.indexOf(filterTerm) > -1) {
        input.parentElement.classList.remove("hidden")
        resultCount++
      } else {
        input.parentElement.classList.add("hidden")
      }
    })

    this.emptyStateTarget.classList.toggle("hidden", resultCount !== 0)

    // Auto-highlight first visible result
    const firstVisible = this.inputTargets.find(i => !i.parentElement.classList.contains("hidden"))
    if (firstVisible) {
      this.selectedItemIndex = 0
      this.focusSelectedInput()
    }
  }

  // Keyboard

  keyDownPressed() {
    if (this.selectedItemIndex !== null) {
      this.selectedItemIndex++
    } else {
      this.selectedItemIndex = 0
    }

    this.focusSelectedInput()
  }

  keyUpPressed() {
    if (this.selectedItemIndex !== null) {
      this.selectedItemIndex--
    } else {
      this.selectedItemIndex = -1
    }

    this.focusSelectedInput()
  }

  keyEnterPressed(event) {
    event.preventDefault()
    const option = this.itemTargets.find(item => item.ariaCurrent === "true")

    if (option) {
      option.click()
    }
  }

  focusSelectedInput() {
    const visibleInputs = this.inputTargets.filter(input => !input.parentElement.classList.contains("hidden"))

    this.wrapSelectedInputIndex(visibleInputs.length)

    visibleInputs.forEach((input, index) => {
      if (index == this.selectedItemIndex) {
        input.parentElement.ariaCurrent = "true"
        input.parentElement.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' })
      } else {
        input.parentElement.ariaCurrent = "false"
      }
    })
  }

  wrapSelectedInputIndex(length) {
    this.selectedItemIndex = ((this.selectedItemIndex % length) + length) % length
  }

  handleBadgeInputBackspace(event) {
    if (this.badgeInputTarget.value !== "") return

    const checkedInputs = this.inputTargets.filter(input => input.checked)
    const lastChecked = checkedInputs[checkedInputs.length - 1]

    if (lastChecked) {
      lastChecked.checked = false
      lastChecked.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }
}
