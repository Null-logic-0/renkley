import { Controller } from "@hotwired/stimulus"

// Slide-in mobile nav drawer: opens from the burger, closes via backdrop
// click, Escape, the close button, or picking a link — and locks page
// scroll while open.
export default class extends Controller {
  static targets = ["menu", "burger", "backdrop"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.menuTarget.classList.add("is-active")
    this.backdropTarget.classList.add("is-active")
    this.burgerTarget.classList.add("is-active")
    this.burgerTarget.setAttribute("aria-expanded", "true")
    document.body.classList.add("rk-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
    this.isOpen = true
  }

  close() {
    this.menuTarget.classList.remove("is-active")
    this.backdropTarget.classList.remove("is-active")
    this.burgerTarget.classList.remove("is-active")
    this.burgerTarget.setAttribute("aria-expanded", "false")
    document.body.classList.remove("rk-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
    this.isOpen = false
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }
}
