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
    L.tileLayer("https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png?lang=eo", {
      attribution: '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map)
    L.marker([this.latitude, this.longitude]).addTo(map)
  }
}
</script>

<style scoped>

</style>
