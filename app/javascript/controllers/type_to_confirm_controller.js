import { Controller } from "@hotwired/stimulus"

// Gates a destructive submit button behind typing an exact confirmation
// string first — e.g. Settings → "Delete workspace" requires typing the
// workspace name before the button becomes clickable.
export default class extends Controller {
  static targets = ["input", "submit"]
  static values = { expected: String }

  check() {
    this.submitTarget.disabled = this.inputTarget.value.trim() !== this.expectedValue
  }
}
