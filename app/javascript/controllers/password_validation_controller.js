import { Controller } from "@hotwired/stimulus"

// Live-toggles the password requirements checklist as the user types —
// purely visual feedback; the server re-validates every rule on submit
// regardless of what this shows.
export default class extends Controller {
  static targets = ["password", "confirmation", "length", "complexity", "match"]

  check() {
    const password = this.passwordTarget.value
    const confirmation = this.hasConfirmationTarget ? this.confirmationTarget.value : ""

    this.toggle(this.lengthTarget, password.length >= 8)
    this.toggle(this.complexityTarget, /[A-Za-z]/.test(password) && /\d/.test(password))
    this.toggle(this.matchTarget, password.length > 0 && password === confirmation)
  }

  toggle(target, satisfied) {
    target.classList.toggle("is-satisfied", satisfied)
  }
}
