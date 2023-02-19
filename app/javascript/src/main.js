import Vue from 'vue/dist/vue.esm'
import MapoVidmaniero from '../components/MapoVidmaniero'

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('vue-mapo-vidmaniero')) {
    const mapoVidManiero = new Vue({
      el: '#vue-mapo-vidmaniero',
      name: 'Mapo vidmaniero',
      components: {
        MapoVidmaniero
      }
    })
  }
})
