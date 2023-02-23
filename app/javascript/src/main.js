import Vue from 'vue/dist/vue.esm'
import MapoVidmaniero from '../components/MapoVidmaniero'
import RegistritajEventoj from '../components/statistikoj/RegistritajEventoj'
import KvantoRegistritajUzantoj from '../components/statistikoj/KvantoRegistritajUzantoj'
import KvantoRegistritajEventoj from '../components/statistikoj/KvantoRegistritajEventoj'
import EventojLauMonatoj from '../components/statistikoj/EventojLauMonatoj'
import EventojRetajKajFizikaj from '../components/statistikoj/EventojRetajKajFizikaj'
import Serchilo from '../components/serchilo/Serchilo'
import SerchiloNavbar from '../components/serchilo/SerchiloNavbar'
import EventaMapo from '../components/eventoj/EventaMapo'
import PartoprenantaButono from '../components/eventoj/partoprenantoj/PartoprenantaButono'
import VideoNova from '../components/VideoNova'

import moment from 'moment'
moment.locale('eo')
Vue.prototype.$moment = moment

document.addEventListener('DOMContentLoaded', () => {
  const vueapp = new Vue({
    el: '#vueapp',
    name: 'App',
    components: {
      MapoVidmaniero,
      RegistritajEventoj,
      KvantoRegistritajUzantoj,
      KvantoRegistritajEventoj,
      EventojLauMonatoj,
      EventojRetajKajFizikaj,
      Serchilo,
      SerchiloNavbar,
      EventaMapo,
      PartoprenantaButono,
      VideoNova
    }
  })
})
