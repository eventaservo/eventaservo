import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="short-url"
export default class extends Controller {
  static targets = ['instruisto']

  connect () { }

  toggleUserInstruistoDetails () {
    $('#instruisto-details').toggleClass('d-none')
  }
}
