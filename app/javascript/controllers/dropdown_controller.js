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
    this.clampToViewport()
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.element.classList.remove("is-active")
    this.isOpen = false
    this.element.style.removeProperty("--rk-dropdown-shift")
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onKeydown)
  }

  // Bulma's own left:0/right:0 dropdown-menu positioning is relative to the
  // trigger only — it has no idea where the viewport edge is. A trigger that
  // ends up near either edge (very likely in a topbar, and guaranteed once
  // other elements shrink away at narrow widths) leaves the menu with no
  // fallback and it bleeds off-screen. Shift it back in as a last step,
  // rather than hand-picking align: left/right per breakpoint per instance.
  clampToViewport() {
    const menu = this.element.querySelector(".dropdown-menu")
    if (!menu) return

    // document.documentElement.clientWidth (the true CSS layout viewport,
    // scrollbar excluded) rather than window.innerWidth, which can report a
    // wider value than what's actually laid out on screen.
    const viewportWidth = document.documentElement.clientWidth
    const margin = 8
    const rect = menu.getBoundingClientRect()
    let shift = 0

    if (rect.right > viewportWidth - margin) {
      shift = (viewportWidth - margin) - rect.right
    } else if (rect.left < margin) {
      shift = margin - rect.left
    }

    this.element.style.setProperty("--rk-dropdown-shift", `${shift}px`)
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
