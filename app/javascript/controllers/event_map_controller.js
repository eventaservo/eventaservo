import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="event-map"
export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
  }

  connect() {
    this.drawMap(this.latitudeValue, this.longitudeValue)
  }

  drawMap(latitude, longitude) {
    const map = L.map('event_map_container').setView([latitude, longitude], 13)
    L.tileLayer(
      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZXZlbnRhc2Vydm8iLCJhIjoiY2s2OGcxaWU5MDRtYzNucWZqdXRicnFpMyJ9.HRdmn4ful40N4svL9ix8vA',
      {
        attribution:
          '<a href="https://www.openstreetmap.org">OpenStreetMap</a>',
        id: 'mapbox/streets-v12',
      }
    ).addTo(map)
    L.marker([latitude, longitude]).addTo(map)
  }
}
