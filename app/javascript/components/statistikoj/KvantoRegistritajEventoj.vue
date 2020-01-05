<template>
  <div id="kvanto_registritaj_eventoj"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "KvantoRegistritajEventoj",
  mounted () {
    axios.get("/statistikoj.json", {
      params: { q: "kvanto_registritaj_eventoj" }
    }).then(response => {
      this.diagramo(response.data.monatoj, response.data.kvantoj)
    })
  },
  methods: {
    diagramo (monatoj, kvantoj) {
      Highcharts.chart("kvanto_registritaj_eventoj", {
        colors: ["#28a745"],
        chart: {
          type: "spline"
        },
        title: {
          text: "Registritaj eventoj"
        },
        legend: {
          enabled: false
        },
        xAxis: {
          categories: monatoj,
          crosshair: true
        },
        yAxis: {
          min: 0,
          title: {
            text: "Eventoj"
          }
        },
        plotOptions: {
          spline: {
            dataLabels: {
              enabled: true
            }
          }
        },
        tooltip: {
          headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
          pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + '<td style="padding:0"><b>{point.y} eventoj</b></td></tr>',
          footerFormat: "</table>",
          shared: true,
          useHTML: true
        },
        series: [
          {
            name: "Kvanto",
            data: kvantoj
          }
        ]
      })
    }
  }
}
</script>

<style scoped>

</style>
