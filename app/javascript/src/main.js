import Vue from "vue/dist/vue.esm"
import EventaMapo from "../components/eventoj/EventaMapo"

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
    components: {}
  })
})
