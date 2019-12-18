import Vue from 'vue/dist/vue.esm'
import Mallongilo from "../../components/eventoj/Mallongilo";
import axios from 'axios'

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById("mallongilo")) {
    const mallongilo = new Vue({
      el: '#mallongilo',
      components: {
        mallongilo: Mallongilo
      }
    })
  }
});
