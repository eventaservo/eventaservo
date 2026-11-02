import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ['searchTerm']
  static values = {
    url: { type: String, default: '/serchilo' }
  }

  connect() {}

  goToSearchPage(event) {
    const searchTerm = this.searchTermTarget.value.trim()

    clearTimeout(this._timer)

    const baseUrl = this.urlValue || '/serchilo'
    const separator = baseUrl.includes('?') ? '&' : '?'
    const targetUrl = `${baseUrl}${separator}query=${encodeURIComponent(searchTerm)}`

    if (event.keyCode === 13 && searchTerm) {
      window.location.href = targetUrl
    } else if (searchTerm) {
      this._timer = setTimeout(() => {
        window.location.href = targetUrl
      }, 2500)
    }
  }
}
