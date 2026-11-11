import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dismissible"
export default class extends Controller {
  static values = {
    autoDismiss: Number
  }

  connect() {
    if (this.hasAutoDismissValue && this.autoDismissValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.autoDismissValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.classList.add("tw:opacity-0")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
