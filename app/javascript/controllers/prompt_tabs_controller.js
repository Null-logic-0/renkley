import { Controller } from "@hotwired/stimulus"

// Filters pre-rendered prompt rows by category client-side — no re-fetch.
export default class extends Controller {
  static targets = ["tab", "row"]

  select(event) {
    const category = event.currentTarget.dataset.category

    this.tabTargets.forEach((tab) => {
      const active = tab === event.currentTarget
      tab.classList.toggle("is-active", active)
      tab.setAttribute("aria-selected", String(active))
    })

    this.rowTargets.forEach((row) => {
      row.hidden = category !== "all" && row.dataset.category !== category
    })
  }
}
