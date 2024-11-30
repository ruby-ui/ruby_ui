import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--combobox"
export default class extends Controller {
  static values = {
    multiple: Boolean, // controls if select input accepts multiple selected options or not
    term: String // text used on multiple combobox to indicate how many items are selected, eg. `4 items`
  }

  static targets = [
    "dialog", // dialog that shows combobox options
    "datalistOption", // visual options inside dialog
    "emptyState", // element displayed when the search doesn't return results
    "searchInput", // search input used for filtering options
    "select", // hidden select that control combobox value
    "trigger", // button that opens dialog
    "triggerContent" // button content used to display selected values
  ]

  selectedOptionIndex = null

  connect() {
    this.initSelect()
    this.updateTriggerContent()
  }

  // Init select using datalist options
  initSelect() {
    if (this.multipleValue) {
      this.selectTarget.setAttribute("multiple", true)
    }

    this.datalistOptionTargets.forEach((datalistOption) => {
      const selectOption = document.createElement("option")
      selectOption.value = datalistOption.dataset.value
      selectOption.selected = datalistOption.ariaSelected === "true"
      this.selectTarget.appendChild(selectOption)
    })
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
    this.selectedOptionIndex = null
    this.datalistOptionTargets.forEach(option => option.ariaCurrent = "false")
    this.dialogTarget.close()
  }

  // Close dialog When dialog backdrop is clicked
  handleOutsideClick(event) {
    if (event.target === this.dialogTarget) {
      this.closeDialog()
    }
  }

  toggleOption(event) {
    const datalistOption = event.currentTarget

    if (this.multipleValue) {
      this.toggleOptionInMultiple(datalistOption)
    } else {
      this.toggleOptionInSingle(datalistOption)
    }

    this.updateTriggerContent()
  }

  toggleOptionInMultiple(datalistOption) {
    if (datalistOption.ariaSelected !== "true") {
      this.selectSelectOption(datalistOption.dataset.value)
      this.selectDatalistOption(datalistOption)
    } else {
      this.unselectSelectOption(datalistOption.dataset.value)
      this.unselectDatalistOption(datalistOption)
    }
  }

  toggleOptionInSingle(datalistOption) {
    if (datalistOption.ariaSelected !== "true") {
      this.selectSelectOption(datalistOption.dataset.value)
      this.selectDatalistOption(datalistOption)
      this.unselectOtherDatalistOptions(datalistOption)
    } else {
      this.unselectSelectOption(datalistOption.dataset.value)
      this.unselectDatalistOption(datalistOption)
    }

    this.closeDialog()
  }

  selectSelectOption(value) {
    const options = this.selectTarget.options

    for (let i = 0; i < options.length; i++) {
      const option = options[i]
      if (!option.selected && option.value == value) {
        option.selected = true
        break
      }
    }
  }

  unselectSelectOption(value) {
    const options = this.selectTarget.options

    for (let i = 0; i < options.length; i++) {
      const option = options[i]
      if (option.selected && option.value == value) {
        option.selected = false
        break
      }
    }
  }

  unselectOtherDatalistOptions(selectedOption) {
    this.datalistOptionTargets
      .filter(other => other !== selectedOption && other.ariaSelected === "true")
      .forEach(other => this.unselectDatalistOption(other))
  }

  selectDatalistOption(option) {
    option.ariaSelected = "true"
  }

  unselectDatalistOption(option) {
    option.ariaSelected = "false"
  }

  updateTriggerContent() {
    if (this.multipleValue) {
      this.updateTriggerContentInMultiple()
    } else {
      this.updateTriggerContentInSingle()
    }
  }

  // Get option data-text or textContent and updates ComboboxTrigger content.
  updateTriggerContentInSingle() {
    const selectedOption = this.datalistOptionTargets.find(option => option.ariaSelected === "true")

    if (selectedOption) {
      const text = selectedOption.dataset.text || selectedOption.innerText
      this.triggerContentTarget.innerText = text
    } else {
      this.triggerContentTarget.innerText = this.triggerTarget.dataset.placeholder
    }
  }

  updateTriggerContentInMultiple() {
    let selectedCount = 0
    let selectedOption

    this.datalistOptionTargets.forEach((option) => {
      if (option.ariaSelected === "true") {
        selectedCount++
        selectedOption = option
      }
    })

    if (selectedCount === 0) {
      this.triggerContentTarget.innerText = this.triggerTarget.dataset.placeholder
    } else if (selectedCount === 1) {
      const text = selectedOption.dataset.text || selectedOption.innerText
      this.triggerContentTarget.innerText = text
    } else {
      this.triggerContentTarget.innerText = `${selectedCount} ${this.termValue}`
    }
  }

  filterOptions(e) {
    if (["ArrowDown", "ArrowUp", "Tab", "Enter"].includes(e.key)) {
      return
    }

    const filterTerm = this.searchInputTarget.value.toLowerCase()
    let resultCount = 0

    this.selectedOptionIndex = null

    this.datalistOptionTargets.forEach((option) => {
      const text = option.dataset.text?.toLowerCase() || option.innerText.toLowerCase()

      option.ariaCurrent = "false"

      if (text.indexOf(filterTerm) > -1) {
        option.classList.remove("hidden")
        resultCount++
      } else {
        option.classList.add("hidden")
      }
    })

    this.emptyStateTarget.classList.toggle("hidden", resultCount !== 0)
  }

  keyDownPressed() {
    if (this.selectedOptionIndex !== null) {
      this.selectedOptionIndex++
    } else {
      this.selectedOptionIndex = 0
    }

    this.focusSelectedOption()
  }

  keyUpPressed() {
    if (this.selectedOptionIndex !== null) {
      this.selectedOptionIndex--
    } else {
      this.selectedOptionIndex = -1
    }

    this.focusSelectedOption()
  }

  focusSelectedOption() {
    const visibleOptions = this.datalistOptionTargets.filter(option => !option.classList.contains("hidden"))

    this.wrapSelectedOptionIndex(visibleOptions.length)

    visibleOptions.forEach((option, index) => {
      option.ariaCurrent = index == this.selectedOptionIndex ? "true" : "false"
      if (option.ariaCurrent === "true") {
        option.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' })
      }
    })
  }

  keyEnterPressed(event) {
    event.preventDefault()
    const option = this.datalistOptionTargets.find(option => option.ariaCurrent === "true")

    if (option) {
      option.click()
    }
  }

  wrapSelectedOptionIndex(length) {
    this.selectedOptionIndex = ((this.selectedOptionIndex % length) + length) % length
  }
}
