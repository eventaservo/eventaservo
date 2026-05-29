import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash-message"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("fade")
    }, 5000)
  }
}
