import Vue from "vue/dist/vue.esm"
import RegistritajEventoj from "../components/statistikoj/RegistritajEventoj"
import KvantoRegistritajUzantoj from "../components/statistikoj/KvantoRegistritajUzantoj"
import KvantoRegistritajEventoj from "../components/statistikoj/KvantoRegistritajEventoj"
import EventojLauMonatoj from "../components/statistikoj/EventojLauMonatoj"

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("statistikoj")) {
    const statistikoj = new Vue({
      el: "#statistikoj",
      components: {
        RegistritajEventoj,
        KvantoRegistritajUzantoj,
        KvantoRegistritajEventoj,
        EventojLauMonatoj
      }
    })
  }
})
