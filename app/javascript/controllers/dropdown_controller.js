import { Controller } from "@hotwired/stimulus"

// Generic open/close for any Bulma .dropdown — the account menu, the
// date-range filter, notifications, etc. all share this one controller
// instead of each hand-rolling open/close/outside-click/Escape.
export default class extends Controller {
  connect() {
    this.onDocumentClick = this.onDocumentClick.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.element.classList.add("is-active")
    this.isOpen = true
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.element.classList.remove("is-active")
    this.isOpen = false
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onKeydown)
  }

  onDocumentClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onKeydown)
  }
}
