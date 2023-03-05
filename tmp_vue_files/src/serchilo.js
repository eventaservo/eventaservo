import Vue from 'vue/dist/vue.esm'

import Serchilo from '../components/serchilo/Serchilo'

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('serchilo')) {
    const serchilo = new Vue({
      el: '#serchilo',
      components: {
        Serchilo,
      },
    })
  }
})
