<template>
  <div id="eventoj_lau_monatoj"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "EventojLauMonatoj",
  mounted () {
    axios.get("/statistikoj.json", {
      params: { q: "eventoj_lau_monatoj" }
    }).then(response => {
      this.diagramo(response.data.monatoj, response.data.kvantoj)
    })
  },
  methods: {
    diagramo (monatoj, kvantoj) {
      Highcharts.chart("eventoj_lau_monatoj", {
        colors: ["#28a745"],
        chart: {
          type: "areaspline"
        },
        title: {
          text: "Okazantaj eventoj laŭ monatoj"
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
          areaspline: {
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
