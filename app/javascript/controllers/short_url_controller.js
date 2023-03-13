import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// Connects to data-controller="short-url"
export default class extends Controller {
  static targets = ['eventId', 'url']

  connect() {}

  check() {
    const path = '/iloj/mallongilo_disponeblas'
    const headers = { Accept: 'text/vnd.turbo-stream.html' }

    const normalizedShortUrl = this.urlTarget.value
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-zA-Z0-9_-]/g, '')
    this.urlTarget.value = normalizedShortUrl

    const searchParams = new URLSearchParams({
      id: this.eventIdTarget.value,
      mallongilo: normalizedShortUrl,
    })

    fetch(`${path}?${searchParams}`, { headers: headers })
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html)
      })
  }
}
