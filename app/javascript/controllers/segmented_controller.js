import { Controller } from "@hotwired/stimulus"

// The selected option's visual state comes from plain CSS (:has()) — this
// controller only dispatches a "segmented:change" event with the newly
// selected value so a host page can react (e.g. swap displayed content).
// Attach with data-action="change->segmented#select" on the .seg element.
export default class extends Controller {
  select(event) {
    this.element.dispatchEvent(
      new CustomEvent("segmented:change", {
        bubbles: true,
        detail: { value: event.target.value },
      })
    )
  }
}
