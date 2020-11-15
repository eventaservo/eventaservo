import Vue from "vue/dist/vue.esm";
import Changelog from '../components/Changelog'
document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("changelog")) {
    const changelog = new Vue({
      el: "#changelog",
      components: {
        Changelog
      },
    });
  }
});
