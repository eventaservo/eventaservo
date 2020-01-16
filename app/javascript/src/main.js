import Vue from "vue/dist/vue.esm"
import EventaMapo from "../components/eventoj/EventaMapo"
import LauRetumilo from "../components/analizado/LauRetumilo"
import LauSistemo from "../components/analizado/LauSistemo"
import LauVidmaniero from "../components/analizado/LauVidmaniero"
import LauTago from "../components/analizado/LauTago"
import MapoVidmaniero from "../components/MapoVidmaniero"
import Mallongilo from "../components/eventoj/Mallongilo"

// import Loading from "vue-loading-overlay"
// import "vue-loading-overlay/dist/vue-loading.css"
// Vue.use(Loading, {
//   color: "blue",
//   isFullPage: false
// })

document.addEventListener("DOMContentLoaded", () => {
  Vue.component("eventa-mapo", EventaMapo)

  const app = new Vue({
    el: "#app",
    name: "app",
    data: {
      texto: "APP data"
    },
    components: {
      MapoVidmaniero,
      LauRetumilo,
      LauSistemo,
      LauVidmaniero,
      LauTago,
      Mallongilo
    }
  })
})
