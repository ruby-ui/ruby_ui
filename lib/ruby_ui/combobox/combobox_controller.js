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

    // Track mouse state to distinguish click-focus from tab-focus
    this._mouseDown = false
    this.element.addEventListener("mousedown", () => { this._mouseDown = true })
    this.element.addEventListener("mouseup", () => { setTimeout(() => { this._mouseDown = false }, 0) })
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
    if (event && event.type !== "focusin" && event.type !== "focus") event.preventDefault()

    // focusin/focus: only open on keyboard focus (tab), not mouse click
    if (event && (event.type === "focusin" || event.type === "focus")) {
      if (this._mouseDown || this.triggerTarget.ariaExpanded === "true" || this._closingPopover) return
    }

    this.updatePopoverPosition()
    this.updatePopoverWidth()
    this.triggerTarget.ariaExpanded = "true"
    this.selectedItemIndex = null
    this.itemTargets.forEach(item => item.ariaCurrent = "false")
    this.popoverTarget.showPopover()

    // Always show all items on open; filter only on user typing
    this.applyFilter("")

    if (this.hasBadgeInputTarget) {
      this.badgeInputTarget.value = ""
    }
  }

  closePopover() {
    this._closingPopover = true
    this.triggerTarget.ariaExpanded = "false"
    this.popoverTarget.hidePopover()
    setTimeout(() => this._closingPopover = false, 200)
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
    if (!this.hasTriggerContentTarget) return

    const checkedInputs = this.inputTargets.filter(input => input.checked)

    if (checkedInputs.length === 0) {
      this.triggerContentTarget.innerText = this.triggerTarget.dataset.placeholder
      this.triggerContentTarget.classList.add("text-muted-foreground")
    } else if (this.termValue && checkedInputs.length > 1) {
      this.triggerContentTarget.innerText = `${checkedInputs.length} ${this.termValue}`
      this.triggerContentTarget.classList.remove("text-muted-foreground")
    } else {
      this.triggerContentTarget.innerText = checkedInputs.map((input) => this.inputContent(input)).join(", ")
      this.triggerContentTarget.classList.remove("text-muted-foreground")
    }
  }

  updateInputTrigger() {
    if (!this.hasInputTriggerTarget) return
    const checked = this.inputTargets.find(i => i.checked)
    this.inputTriggerTarget.value = checked ? this.inputContent(checked) : ""
  }

  // NOTE: badge classes mirror ComboboxBadge Ruby component. Update both if styles change.
  updateBadges() {
    if (!this.hasBadgeContainerTarget) return

    // Remove existing badges
    this.triggerTarget.querySelectorAll("[data-combobox-badge]").forEach(el => el.remove())

    const checkedInputs = this.inputTargets.filter(input => input.checked)

    // Toggle trigger height: h-9 when empty, h-auto min-h-9 when badges exist
    if (checkedInputs.length > 0) {
      this.triggerTarget.classList.remove("h-9")
      this.triggerTarget.classList.add("h-auto", "min-h-9")
    } else {
      this.triggerTarget.classList.remove("h-auto", "min-h-9", "pt-1.5")
      this.triggerTarget.classList.add("h-9")
    }

    checkedInputs.forEach(input => {
      const badge = document.createElement("span")
      badge.setAttribute("data-combobox-badge", "")
      badge.className = "inline-flex items-center gap-1 rounded-md border bg-secondary px-1.5 py-0.5 text-xs font-medium text-secondary-foreground"
      badge.dataset.value = input.value

      badge.appendChild(document.createTextNode(this.inputContent(input).trim()))

      const btn = document.createElement("button")
      btn.type = "button"
      btn.setAttribute("aria-label", "Remove")
      btn.className = "rounded-sm opacity-50 hover:opacity-100 focus-visible:outline-none"

      btn.addEventListener("click", (e) => {
        e.preventDefault()
        e.stopPropagation()
        e.stopImmediatePropagation()
        const target = this.inputTargets.find(i => i.value === input.value)
        if (target) {
          target.checked = false
          this.updateBadges()
          this.updateClearButton()
        }
      })

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
      svg.classList.add("pointer-events-none")

      const path1 = document.createElementNS("http://www.w3.org/2000/svg", "path")
      path1.setAttribute("d", "M18 6 6 18")
      const path2 = document.createElementNS("http://www.w3.org/2000/svg", "path")
      path2.setAttribute("d", "m6 6 12 12")

      svg.appendChild(path1)
      svg.appendChild(path2)
      btn.appendChild(svg)
      badge.appendChild(btn)

      // Insert badge directly in trigger, before the text input
      this.badgeInputTarget.insertAdjacentElement("beforebegin", badge)
    })

    // Add top padding only when badges wrap to multiple lines
    // Class "pt-1.5" is referenced in ComboboxBadgeTrigger for Tailwind to compile it
    const badges = this.triggerTarget.querySelectorAll("[data-combobox-badge]")
    if (badges.length > 0 && this.badgeInputTarget.offsetTop > badges[0].offsetTop) {
      this.triggerTarget.classList.add("pt-1.5")
    } else {
      this.triggerTarget.classList.remove("pt-1.5")
    }
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

    // Auto-highlight first visible result (without scrolling to avoid page jump)
    this.itemTargets.forEach(item => item.ariaCurrent = "false")
    const firstVisible = this.inputTargets.find(i => !i.parentElement.classList.contains("hidden"))
    if (firstVisible) {
      this.selectedItemIndex = 0
      firstVisible.parentElement.ariaCurrent = "true"
    }
  }

  // Keyboard

  keyDownPressed(event) {
    event.preventDefault()
    if (this.selectedItemIndex !== null) {
      this.selectedItemIndex++
    } else {
      this.selectedItemIndex = 0
    }

    this.focusSelectedInput()
  }

  keyUpPressed(event) {
    event.preventDefault()
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
