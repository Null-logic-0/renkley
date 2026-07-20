import { Controller } from "@hotwired/stimulus"

// Fades out and removes the element it's attached to — used for dismissible
// flash messages and banners. Purely visual: closing just removes it from
// the current page, nothing is persisted.
export default class extends Controller {
  close() {
    const remove = () => this.element.remove()
    // transitionend covers the normal case; the timeout is a fallback for
    // reduced-motion, an interrupted transition, or any other reason the
    // event never fires — the element must not get stuck invisible-but-present.
    this.element.addEventListener("transitionend", remove, { once: true })
    setTimeout(remove, 200)
    this.element.style.opacity = "0"
  }
}
