import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ['searchTerm']

  connect() {}

  goToSearchPage(event) {
    const searchTerm = this.searchTermTarget.value.trim()

    clearTimeout(this._timer)

    if (event.keyCode === 13 && searchTerm) {
      window.location.href = `/serchilo?query=${encodeURIComponent(searchTerm)}`
    } else if (searchTerm) {
      this._timer = setTimeout(() => {
        window.location.href = `/serchilo?query=${encodeURIComponent(searchTerm)}`
      }, 2500)
    }
  }
}
