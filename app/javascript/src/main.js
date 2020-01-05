import Vue from "vue/dist/vue.esm"

// import Loading from "vue-loading-overlay"
// import "vue-loading-overlay/dist/vue-loading.css"
// Vue.use(Loading, {
//   color: "blue",
//   isFullPage: false
// })

document.addEventListener("DOMContentLoaded", () => {
  const app = new Vue({
    el: "#app",
    name: "app",
    data: {
      texto: "APP data"
    },
    components: {
    }
  })
})
