import Vue from "vue/dist/vue.esm"
import Partneroj from "../components/organizoj/Partneroj"

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("vue-organizoj")) {
    const featured = new Vue({
      el: "#vue-organizoj",
      components: {
        Partneroj
      }
    })
  }
})
