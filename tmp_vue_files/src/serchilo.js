import Vue from "vue/dist/vue.esm"

import Serchilo from '../components/serchilo/Serchilo'
import SerchiloNavbar from '../components/serchilo/SerchiloNavbar'

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("serchilo")) {
    const serchilo = new Vue({
      el: "#serchilo",
      components: {
        Serchilo
      }
    })
  }
})

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("serchilo_navbar")) {
    const serchilo = new Vue({
      el: "#serchilo_navbar",
      components: {
        SerchiloNavbar
      }
    })
  }
})
