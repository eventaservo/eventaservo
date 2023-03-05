import Vue from "vue/dist/vue.esm";
import PrelegoForm from '../components/uzantoj/PrelegoForm'

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("profilo")) {
    const featured = new Vue({
      el: "#profilo",
      components: {
        PrelegoForm
      },
    });
  }
});
