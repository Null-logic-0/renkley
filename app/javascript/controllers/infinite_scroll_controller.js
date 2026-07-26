import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.originalHTML = this.listTarget.innerHTML
    this.appended = 0
    this.maxAppends = 6
    this.onScroll = this.onScroll.bind(this)
    this.element.addEventListener("scroll", this.onScroll)
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    const { scrollTop, scrollHeight, clientHeight } = this.element
    const nearBottom = scrollHeight - scrollTop - clientHeight < 48

    if (nearBottom && this.appended < this.maxAppends) {
      this.listTarget.insertAdjacentHTML("beforeend", this.originalHTML)
      this.appended += 1
    }
  }
}
