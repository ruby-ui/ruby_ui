import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="command"
export default class extends Controller {
    static targets = ["input", "group", "item"]

    connect() {
        this.inputTarget.focus()
    }

    filter(e) {
        console.log("filtering")
        const query = e.target.value.toLowerCase()
        this.itemTargets.forEach((el) => {
            const text = el.dataset.value.toLowerCase()
            const match = text.includes(query)
            el.classList.toggle("hidden", !match)
        })
        this.hideEmptyGroups()
    }

    hideEmptyGroups() {
        this.groupTargets.forEach((el) => {
            const hidden = el.querySelectorAll("[data-command-target='item']:not(.hidden)").length === 0
            el.classList.toggle("hidden", hidden)
        })
    }
}
