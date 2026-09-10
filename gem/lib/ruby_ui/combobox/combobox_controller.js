import { Controller } from "@hotwired/stimulus";
import { computePosition, autoUpdate, offset, flip } from "@floating-ui/dom";

// Connects to data-controller="ruby-ui--combobox"
export default class extends Controller {
  static values = {
    term: String,
    minPopoverWidth: { type: Number, default: 240 },
    placement: { type: String, default: "bottom-start" }
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
    this.stopAutoUpdate()
    // Nothing is left to wait for the exit animation, so apply the pending hide now.
    if (this.hasPopoverTarget) this.settleExit(this.popoverTarget)
  }

  handlePopoverToggle(event) {
    // Keep ariaExpanded in sync with the actual popover state
    this.triggerTarget.ariaExpanded = event.newState === 'open' ? 'true' : 'false'
  }

  // Still true while the exit animation runs; the window handlers also reach a combobox rendered without a popover.
  get popoverShowing() {
    return this.hasPopoverTarget && this.popoverTarget.matches(":popover-open")
  }

  handleOutsideClick(event) {
    if (!this.popoverShowing) return
    if (this.popoverTarget.contains(event.target)) return
    if (this.triggerTarget.contains(event.target)) return

    this.closePopover()
  }

  handleEscape(event) {
    if (!this.popoverShowing) return

    event.preventDefault()
    this.closePopover()
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

  togglePopover(event) {
    event.preventDefault()

    if (this.triggerTarget.ariaExpanded === "true") {
      this.closePopover()
    } else {
      this.openPopover(event)
    }
  }

  openPopover(event) {
    if (event) event.preventDefault()

    this.updatePopoverPosition()
    this.updatePopoverWidth()
    this.triggerTarget.ariaExpanded = "true"
    this.selectedItemIndex = null
    this.itemTargets.forEach(item => item.ariaCurrent = "false")
    this.popoverTarget.dataset.state = "open"
    // Reopened mid-exit: it is still showing, and the state flip alone brings it back in.
    if (!this.popoverShowing) this.popoverTarget.showPopover()
  }

  closePopover() {
    if (this.popoverTarget.dataset.state === "closed") return

    this.triggerTarget.ariaExpanded = "false"
    this.popoverTarget.dataset.state = "closed"
    this.hideAfterExitAnimation(this.popoverTarget)
  }

  // Positioning keeps running until the popover is hidden, so it does not drift while it fades.
  afterExit(popover) {
    popover.hidePopover()
    this.stopAutoUpdate()
  }

  // Overlay exit — the same block in every overlay controller, so keep them in sync.
  exitAnimationNames = new WeakMap();

  hideAfterExitAnimation(animated) {
    const exitAnimations = animated
      .getAnimations()
      .filter((animation) => animation instanceof CSSAnimation);

    // No exit animation, or no box to run it in: animationend would never fire.
    if (exitAnimations.length === 0) {
      this.settleExit(animated);
      return;
    }

    this.exitAnimationNames.set(animated, exitAnimations.map((animation) => animation.animationName));
    animated.addEventListener("animationend", this.handleExitAnimationEnd);
    animated.addEventListener("animationcancel", this.handleExitAnimationEnd);
  }

  handleExitAnimationEnd = (event) => {
    // animationend bubbles — an animated child must not hide its container.
    if (event.target !== event.currentTarget) return;
    // Closing mid-open cancels the enter animation; only the exit run settles this.
    if (!this.exitAnimationNames.get(event.currentTarget)?.includes(event.animationName)) return;

    this.settleExit(event.currentTarget);
  };

  settleExit(animated) {
    animated.removeEventListener("animationend", this.handleExitAnimationEnd);
    animated.removeEventListener("animationcancel", this.handleExitAnimationEnd);
    // Reopened mid-exit: it is on its way back in, leave it visible.
    if (animated.dataset.state !== "closed") return;

    this.afterExit(animated);
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
    this.stopAutoUpdate()

    this.cleanup = autoUpdate(this.triggerTarget, this.popoverTarget, () => {
      computePosition(this.triggerTarget, this.popoverTarget, {
        placement: this.placementValue,
        middleware: [offset(4), flip()],
      }).then(({ x, y, placement }) => {
        Object.assign(this.popoverTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
        // flip() can resolve to the opposite side, so the slide-in direction follows the resolved value.
        this.popoverTarget.dataset.side = placement.split("-")[0]
      });
    });
  }

  stopAutoUpdate() {
    if (!this.cleanup) return

    this.cleanup()
    this.cleanup = null
  }

  updatePopoverWidth() {
    const width = Math.max(this.triggerTarget.offsetWidth, this.minPopoverWidthValue)
    this.popoverTarget.style.width = `${width}px`
  }
}
