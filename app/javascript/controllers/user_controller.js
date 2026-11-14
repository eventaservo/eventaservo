import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="user"
export default class extends Controller {
  static targets = ['instruisto', 'preleganto']

  connect () { }

  toggleUserInstruistoDetails() {
    document.getElementById('instruisto-details')?.classList.toggle('tw:hidden')
  }

  toggleUserPrelegantoDetails() {
    document.getElementById('preleganto-details')?.classList.toggle('tw:hidden')
  }
}
