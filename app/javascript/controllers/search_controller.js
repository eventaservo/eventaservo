import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ['searchTerm']

  connect() {}

  goToSearchPage(event) {
    const searchTerm = this.searchTermTarget.value
    const url = `/serchilo?query=${searchTerm}`

    clearTimeout(this._timer)

    if (event.keyCode === 13) {
      window.location.href = url
    }

    this._timer = setTimeout(() => {
      window.location.href = url
    }, 2500)
  }
}
