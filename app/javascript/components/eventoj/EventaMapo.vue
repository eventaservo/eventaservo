<template>
  <div id="map" class="event-map"></div>
</template>

<script>
/* global L */

export default {
  name: "EventaMapo",
  props: {
    latitude: Number,
    longitude: Number
  },
  mounted () {
    const map = L.map("map").setView([this.latitude, this.longitude], 13)
    L.tileLayer("https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZXZlbnRhc2Vydm8iLCJhIjoiY2s2OGcxaWU5MDRtYzNucWZqdXRicnFpMyJ9.HRdmn4ful40N4svL9ix8vA", {
      attribution: '<a href="http://www.mapbox.com">Mapbox</a>',
      id: "mapbox/streets-v11",
      access_toke: "pk.eyJ1IjoiZXZlbnRhc2Vydm8iLCJhIjoiY2s2OGcxaWU5MDRtYzNucWZqdXRicnFpMyJ9.HRdmn4ful40N4svL9ix8vA"
    }).addTo(map)
    L.marker([this.latitude, this.longitude]).addTo(map)
  }
}
</script>

<style scoped>

</style>
