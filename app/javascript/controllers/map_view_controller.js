import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="map-view"
export default class extends Controller {
  static values = {
    events: Array,
  }

  connect() {
    this.drawMap()
  }

  drawMap() {
    const map = L.map('map-view-container')
    L.tileLayer(
      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZXZlbnRhc2Vydm8iLCJhIjoiY2s2OGcxaWU5MDRtYzNucWZqdXRicnFpMyJ9.HRdmn4ful40N4svL9ix8vA',
      {
        attribution:
          `© <a href="https://www.mapbox.com/about/maps/">Mapbox</a> © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> <strong><a href="https://www.mapbox.com/map-feedback/" target="_blank">Plibonigi tiun mapon</a></strong>`,
        id: 'mapbox/streets-v12',
      }
    ).addTo(map)
    const bounds = []
    const markers = L.markerClusterGroup({ maxClusterRadius: 20 })
    for (const evento of this.eventsValue) {
      markers.addLayer(
        L.marker([evento.latitude, evento.longitude], {
          icon: this.eventoPinColor(evento.pinColor),
        }).bindPopup(
          `<strong><a href='${evento.ligilo}'>${evento.title}</a></strong><br>` +
            `${evento.date}<br><br>${evento.description}`
        )
      )
      bounds.push([evento.latitude, evento.longitude])
    }

    map.addLayer(markers)
    map.fitBounds(bounds, { padding: [50, 50], maxZoom: 14 })
  }

  eventoPinColor(epc) {
    const markerShadowUrl = '/map_icons/marker-shadow.png'
    const blueIcon = new L.Icon({
      iconUrl: '/map_icons/pin_blue.svg',
      shadowUrl: markerShadowUrl,
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    })

    const greenIcon = new L.Icon({
      iconUrl: '/map_icons/pin_green.svg',
      shadowUrl: markerShadowUrl,
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    })

    const redIcon = new L.Icon({
      iconUrl: '/map_icons/pin_red.svg',
      shadowUrl: markerShadowUrl,
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    })

    const orangeIcon = new L.Icon({
      iconUrl: '/map_icons/pin_orange.svg',
      shadowUrl: markerShadowUrl,
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    })

    const yellowIcon = new L.Icon({
      iconUrl: '/map_icons/pin_yellow.svg',
      shadowUrl: markerShadowUrl,
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41],
    })

    switch (epc) {
      case 'blueIcon':
        return blueIcon
      case 'greenIcon':
        return greenIcon
      case 'yellowIcon':
        return yellowIcon
      case 'orangeIcon':
        return orangeIcon
      default:
        return redIcon
    }
  }
}
