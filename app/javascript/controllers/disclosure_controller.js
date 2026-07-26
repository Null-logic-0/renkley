import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["trigger", "panel", "chevron"]

  toggle() {
    const opening = this.panelTarget.hidden
    this.panelTarget.hidden = !opening
    this.triggerTarget.setAttribute("aria-expanded", String(opening))
    this.chevronTarget?.classList.toggle("is-open", opening)
  }
}
