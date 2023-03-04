import Vue from 'vue/dist/vue.esm'

import VideoKarto from '../components/VideoKarto'
import VideoNova from '../components/VideoNova'
import moment from 'moment'
moment.locale('eo')
Vue.prototype.$moment = moment

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('evento')) {
    const evento = new Vue({
      el: '#evento',
      name: 'Evento',
      components: {
        VideoKarto,
        VideoNova,
      },
    })
  }
})
