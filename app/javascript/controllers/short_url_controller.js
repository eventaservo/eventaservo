import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// Connects to data-controller="short-url"
export default class extends Controller {
  static targets = ['eventId', 'url']

  connect() {}

  check() {
    const path = '/iloj/mallongilo_disponeblas'
    const headers = { Accept: 'text/vnd.turbo-stream.html' }
    fetch(
      `${path}?` +
        new URLSearchParams({
          id: this.eventIdTarget.value,
          mallongilo: this.urlTarget.value,
        }),
      { headers: headers }
    )
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html)
      })
  }
}
