<template>
  <div id="sistemo"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "LauSistemo",
  props: ["sistemoj", "versioj"],
  mounted () {
    axios.get("/admin/analizado_lau_sistemoj.json").then(response => {
      this.diagramo(response.data.sistemoj)
    })
  },
  methods: {
    diagramo (sistemoj) {
      Highcharts.chart("sistemo", {
        credits: { enabled: false },
        chart: { type: "pie" },
        title: { text: "Laŭ sistemo" },
        plotOptions: {
          series: {
            dataLabels: {
              enabled: true,
              format: "{point.name}: {point.y}"
            }
          }
        },
        tooltip: {
          headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
          pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b><br/>'
        },
        series: [{
          name: "Plataformoj",
          colorByPoint: true,
          data: sistemoj
        }]
      })
    }
  }
}
</script>

<style scoped>

</style>
