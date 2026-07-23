import { Controller } from "@hotwired/stimulus"

// Desktop collapse/expand for the sidebar, persisted in localStorage so it
// survives navigation and reloads. This is separate from the mobile
// off-canvas drawer (see the shared navbar controller, reused for that) —
// collapse is a desktop-only concept; the drawer is always full-width when
// open on narrow screens.
const STORAGE_KEY = "rk-sidebar-collapsed"

export default class extends Controller {
  connect() {
    if (localStorage.getItem(STORAGE_KEY) === "true") {
      this.element.classList.add("is-collapsed")
    }
  }

  toggle() {
    const collapsed = this.element.classList.toggle("is-collapsed")
    localStorage.setItem(STORAGE_KEY, collapsed)
  }
}
