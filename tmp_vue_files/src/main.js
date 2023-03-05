import Vue from "vue/dist/vue.esm"
import Mallongilo from "../components/eventoj/Mallongilo"


document.addEventListener("DOMContentLoaded", () => {

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
