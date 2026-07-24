import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Present in the DOM only once the server confirms onboarding is complete
// (see onboarding/_setup_status partial) — connecting is the "done" signal.
export default class extends Controller {
  static values = { url: String, delay: { type: Number, default: 900 } }

  connect() {
    this.timeout = setTimeout(() => Turbo.visit(this.urlValue), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
