import Vue from "vue/dist/vue.esm"
import LauRetumilo from "../components/analizado/LauRetumilo"
import LauSistemo from "../components/analizado/LauSistemo"
import LauVidmaniero from "../components/analizado/LauVidmaniero"
import LauTago from "../components/analizado/LauTago"

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("analizado")) {
    const analizado = new Vue({
      el: "#analizado",
      components: {
        LauRetumilo,
        LauSistemo,
        LauVidmaniero,
        LauTago
      }
    })
  }
})
