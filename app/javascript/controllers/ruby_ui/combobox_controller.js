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
    "triggerContent"
  ]

  selectedItemIndex = null

  connect() {
    this.updateTriggerContent()
  }

  disconnect() {
    if (this.cleanup) { this.cleanup() }
  }

  inputChanged(e) {
    this.updateTriggerContent()

    if (e.target.type == "radio") {
      this.closePopover()
    }

    if (this.hasToggleAllTarget && !e.target.checked) {
      this.toggleAllTarget.checked = false
    }
  }

  inputContent(input) {
    return input.dataset.text || input.parentElement.textContent
  }

  toggleAllItems() {
    const isChecked = this.toggleAllTarget.checked
    this.inputTargets.forEach(input => input.checked = isChecked)
    this.updateTriggerContent()
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

  openPopover(event) {
    event.preventDefault()

    this.updatePopoverPosition()
    this.updatePopoverWidth()
    this.triggerTarget.ariaExpanded = "true"
    this.selectedItemIndex = null
    this.itemTargets.forEach(item => item.ariaCurrent = "false")
    this.popoverTarget.showPopover()
  }

  closePopover() {
    this.triggerTarget.ariaExpanded = "false"
    this.popoverTarget.hidePopover()
  }

  filterItems(e) {
    if (["ArrowDown", "ArrowUp", "Tab", "Enter"].includes(e.key)) {
      return
    }

    const filterTerm = this.searchInputTarget.value.toLowerCase()

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
  }

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

  keyEnterPressed(event) {
    event.preventDefault()
    const option = this.itemTargets.find(item => item.ariaCurrent === "true")

    if (option) {
      option.click()
    }
  }

  wrapSelectedInputIndex(length) {
    this.selectedItemIndex = ((this.selectedItemIndex % length) + length) % length
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
}
