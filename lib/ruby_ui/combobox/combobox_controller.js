import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--combobox"
export default class extends Controller {
  static values = {
    term: String
  }

  static targets = [
    "input",
    "dialog",
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

  inputChanged(e) {
    this.updateTriggerContent()

    if (e.target.type == "radio") {
      this.closeDialog()
    }
  }

  inputContent(input) {
    return input.dataset.text || input.parentElement.innerText
  }

  updateTriggerContent() {
    const checkedInputs = this.inputTargets.filter(input => input.checked)

    if (checkedInputs.length == 0) {
      this.triggerContentTarget.innerText = this.triggerTarget.dataset.placeholder
    } else if (checkedInputs.length === 1) {
      this.triggerContentTarget.innerText = this.inputContent(checkedInputs[0])
    } else {
      this.triggerContentTarget.innerText = `${checkedInputs.length} ${this.termValue}`
    }
  }

  openDialog(event) {
    event.preventDefault()

    document.body.classList.add('overflow-hidden')
    this.triggerTarget.ariaExpanded = "true"
    this.dialogTarget.showModal()
  }

  closeDialog() {
    document.body.classList.remove('overflow-hidden')
    this.triggerTarget.ariaExpanded = "false"
    this.selectedItemIndex = null
    this.itemTargets.forEach(item => item.ariaCurrent = "false")
    this.dialogTarget.close()
  }

  handleOutsideClick(event) {
    if (event.target === this.dialogTarget) {
      this.closeDialog()
    }
  }

  filterItems(e) {
    if (["ArrowDown", "ArrowUp", "Tab", "Enter"].includes(e.key)) {
      return
    }

    const filterTerm = this.searchInputTarget.value.toLowerCase()
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
}
