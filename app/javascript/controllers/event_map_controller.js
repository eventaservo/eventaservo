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
          `© <a href="https://www.mapbox.com/about/maps/">Mapbox</a> © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> <strong><a href="https://www.mapbox.com/map-feedback/" target="_blank">Plibonigi ĉi tiun mapon</a></strong>`,
        id: 'mapbox/streets-v12',
      }
    ).addTo(map)
    L.marker([latitude, longitude], { icon: this.pinColor() }).addTo(map)
  }

  pinColor() {
    const markerShadowUrl = '/map_icons/marker-shadow.png'
    const blueIcon = new L.Icon({
      iconUrl: '/map_icons/pin_blue.svg',
      shadowUrl: markerShadowUrl,
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    })

    return blueIcon
  }
}
