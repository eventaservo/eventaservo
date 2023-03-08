import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="user"
export default class extends Controller {
  static targets = ['instruisto', 'preleganto']

  connect () { }

  toggleUserInstruistoDetails () {
    $('#instruisto-details').toggleClass('d-none')
  }

  toggleUserPrelegantoDetails() {
    $('#preleganto-details').toggleClass('d-none')
  }
}
