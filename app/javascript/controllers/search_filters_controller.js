import { Controller } from "@hotwired/stimulus"

// Submits the search form when a search filter switch changes.
export default class extends Controller {
  submit(event) {
    event.preventDefault()
    this.element.requestSubmit()
  }
}
