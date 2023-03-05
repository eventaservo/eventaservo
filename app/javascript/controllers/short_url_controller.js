import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// Connects to data-controller="short-url"
export default class extends Controller {
  static targets = ['eventId', 'url']

  connect() {}

  check() {
    path = '/iloj/mallongilo_disponeblas'
    headers = { Accept: 'text/vnd.turbo-stream.html' }
    fetch(
      `${this.path}?` +
        new URLSearchParams({
          id: this.eventIdTarget.value,
          mallongilo: this.urlTarget.value,
        }),
      { headers: this.headers }
    )
      .then((response) => response.text())
      .then((html) => {
        console.log(html)
        Turbo.renderStreamMessage(html)
      })
  }
}
