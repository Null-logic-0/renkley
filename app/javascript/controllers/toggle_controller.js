import { Controller } from "@hotwired/stimulus"

// Visual on/off state for a button[role=switch] toggle (Settings →
// Notifications, etc). Purely presentational — flips aria-checked and
// dispatches a "toggle:change" event; anything that needs to act on the
// change (e.g. persisting a preference) listens for that event itself.
export default class extends Controller {
  flip() {
    const on = this.element.getAttribute("aria-checked") !== "true"
    this.element.setAttribute("aria-checked", on)
    this.element.dispatchEvent(
      new CustomEvent("toggle:change", { bubbles: true, detail: { on } })
    )
  }
}
