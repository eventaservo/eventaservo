import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [ "searchTerm" ]

  connect() {
  }

  goToSearchPage(event) {
    if (event.keyCode === 13) {
      const searchTerm = this.searchTermTarget.value
      const url = `/serchilo?query=${searchTerm}`
      window.location.href = url
    }
  }
}
