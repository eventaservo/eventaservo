<template>
  <div id="retumiloj"></div>

</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "LauRetumilo",
  props: ["retumiloj", "versioj"],
  mounted () {
    axios.get("/admin/analizado_lau_retumiloj.json").then(response => {
      this.diagramo(response.data.retumiloj, response.data.versioj)
    })
  },
  methods: {
    diagramo (retumiloj, versioj) {
      Highcharts.chart("retumiloj", {
        credits: { enabled: false },
        chart: { type: "pie" },
        title: { text: "Laŭ retumilo" },
        subtitle: { text: "Alklaku segmenton por vidi versiojn" },
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
        series: [
          {
            name: "Browsers",
            colorByPoint: true,
            data: retumiloj
          }
        ],
        drilldown: { series: versioj }
      })
    }
  }
}
</script>

<style scoped>

</style>
