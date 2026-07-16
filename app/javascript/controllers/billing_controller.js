import { Controller } from "@hotwired/stimulus"

// Toggles pricing cards between monthly and annual amounts.
export default class extends Controller {
  static targets = ["monthlyBtn", "annualBtn", "price"]
  static values = { period: { type: String, default: "annual" } }

  connect() {
    this.render()
  }

  setMonthly() {
    this.periodValue = "monthly"
  }

  setAnnual() {
    this.periodValue = "annual"
  }

  periodValueChanged() {
    this.render()
  }

  render() {
    const isAnnual = this.periodValue === "annual"
    this.monthlyBtnTarget.classList.toggle("is-active", !isAnnual)
    this.annualBtnTarget.classList.toggle("is-active", isAnnual)
    this.priceTargets.forEach((el) => {
      el.textContent = isAnnual ? el.dataset.annual : el.dataset.monthly
    })
  }
}
