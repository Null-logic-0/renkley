import { Controller } from "@hotwired/stimulus"

// Generic modal open/close — Escape key and backdrop click both close it,
// and body scroll is locked while open (reusing the same rk-scroll-lock
// class the mobile nav drawer uses). Wrap a trigger and a shared/_modal
// partial in one data-controller="modal" scope — shared/_modal.html.erb
// already does this for you.
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  open() {
    this.modalTarget.classList.add("is-active")
    document.body.classList.add("rk-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.modalTarget.classList.remove("is-active")
    document.body.classList.remove("rk-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }
}
