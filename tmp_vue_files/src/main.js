import Vue from "vue/dist/vue.esm"
import MapoVidmaniero from "../components/MapoVidmaniero"
import Mallongilo from "../components/eventoj/Mallongilo"


document.addEventListener("DOMContentLoaded", () => {

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
