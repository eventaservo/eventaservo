import Vue from "vue/dist/vue.esm"
import EventaMapo from "../components/eventoj/EventaMapo"
import MapoVidmaniero from "../components/MapoVidmaniero"
import Mallongilo from "../components/eventoj/Mallongilo"

// import Loading from "vue-loading-overlay"
// import "vue-loading-overlay/dist/vue-loading.css"
// Vue.use(Loading, {
//   color: "blue",
//   isFullPage: false
// })

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("vue-eventa-mapo")) {
    const eventaMapo = new Vue({
      el: "#vue-eventa-mapo",
      name: "Eventa mapo",
      components: {
        EventaMapo
      }
    })
  }

  if (document.getElementById("vue-mapo-vidmaniero")) {
    const mapoVidManiero = new Vue({
      el: "#vue-mapo-vidmaniero",
      name: "Mapo vidmaniero",
      components: {
        MapoVidmaniero
      }
    })
  }

  if (document.getElementById("vue-mallongilo")) {
    const mallongilo = new Vue({
      el: "#vue-mallongilo",
      name: "Mallongilo",
      components: {
        Mallongilo
      }
    })
  }
})
