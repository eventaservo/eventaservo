import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="event-user-interested-button"
export default class extends Controller {
  static targets = ['button', 'question']

  connect() {}

  buttonClicked() {
    this.toggle()

    setTimeout(() => {
      this.toggle()
    }, 10_000)
  }

  toggle() {
    this.questionTarget.classList.toggle('d-none')
    this.buttonTarget.classList.toggle('d-none')
  }
}
