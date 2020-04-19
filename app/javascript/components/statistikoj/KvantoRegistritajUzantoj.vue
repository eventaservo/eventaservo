<template>
  <div id="kvanto_registritaj_uzantoj"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "KvantoRegistritajUzantoj",
  mounted () {
    axios.get("/statistikoj.json", {
      params: { q: "kvanto_registritaj_uzantoj" }
    }).then(response => {
      this.diagramo(response.data.monatoj, response.data.kvantoj)
    })
  },
  methods: {
    diagramo (monatoj, kvantoj) {
      Highcharts.chart("kvanto_registritaj_uzantoj", {
        colors: ["#28a745"],
        chart: {
          type: "spline"
        },
        title: {
          text: "Registritaj uzantoj"
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
            text: "Uzantoj"
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
          pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + '<td style="padding:0"><b>{point.y} uzantoj</b></td></tr>',
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
