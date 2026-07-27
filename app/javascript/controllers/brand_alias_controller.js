import { Controller } from "@hotwired/stimulus"

// Adds/removes a brand-alias pill via fetch rather than a real <form> —
// the add-modal renders inside the page's main settings form, and a
// nested <form> is invalid HTML (browsers silently drop the inner
// opening tag), so both actions go through plain requests instead.
export default class extends Controller {
  static targets = ["input"]
  static values = { url: String, createUrl: String }

  remove(event) {
    event.preventDefault()
    this.send(this.urlValue, "DELETE")
  }

  add(event) {
    event.preventDefault()
    const name = this.inputTarget.value.trim()
    if (!name) return

    this.send(this.createUrlValue, "POST", { brand_alias: { name } })
  }

  send(url, method, body) {
    fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        Accept: "text/vnd.turbo-stream.html"
      },
      body: body ? JSON.stringify(body) : undefined
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html))
  }
}
