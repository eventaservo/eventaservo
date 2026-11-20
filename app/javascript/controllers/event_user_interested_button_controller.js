import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="event-user-interested-button"
export default class extends Controller {
  static targets = ['button', 'question']

  connect() {}

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }

  buttonClicked(event) {
    event?.preventDefault()
    this.toggle()

    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }

    this.timeoutId = setTimeout(() => {
      this.timeoutId = null
      this.toggle()
    }, 10_000)
  }

  toggle() {
    this.questionTarget.classList.toggle('tw:hidden')
    this.buttonTarget.classList.toggle('tw:hidden')
  }
}
