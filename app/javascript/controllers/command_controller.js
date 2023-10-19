import { Controller } from "@hotwired/stimulus"
import Fuse from 'fuse.js'

// Connects to data-controller="command"
export default class extends Controller {
    static targets = ["input", "group", "item"]

    connect() {
        this.inputTarget.focus()
        this.searchIndex = this.buildSearchIndex()
    }

    filter(e) {
        const query = e.target.value.toLowerCase()
        // if the length is zero, show all items
        if (query.length === 0) {
            this.showAllItems()
            this.showAllGroups()
            return
        }
        this.hideAllItems()
        this.searchIndex.search(query).forEach((result) => {
            result.item.element.classList.remove("hidden")
        })
        this.hideEmptyGroups()
    }

    hideAllItems() {
        this.itemTargets.forEach((el) => el.classList.add("hidden"))
    }

    showAllItems() {
        this.itemTargets.forEach((el) => el.classList.remove("hidden"))
    }

    hideEmptyGroups() {
        this.groupTargets.forEach((el) => {
            const hidden = el.querySelectorAll("[data-command-target='item']:not(.hidden)").length === 0
            el.classList.toggle("hidden", hidden)
        })
    }

    showAllGroups() {
        this.groupTargets.forEach((el) => el.classList.remove("hidden"))
    }

    buildSearchIndex() {
        // Build a search index from the data-value attributes of the item targets
        const options = {
            keys: ["value"],
            threshold: 0.2,
            includeMatches: true,
        }
        const items = this.itemTargets.map((el) => {
            return { value: el.dataset.value, element: el }
        })
        return new Fuse(items, options)
    }
}
