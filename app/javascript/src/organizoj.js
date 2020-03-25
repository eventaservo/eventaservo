import Vue from "vue/dist/vue.esm"
import Cheforganizoj from "../components/organizoj/Cheforganizoj"

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("vue-organizoj")) {
    const featured = new Vue({
      el: "#vue-organizoj",
      components: {
        Cheforganizoj
      }
    })
  }
})
