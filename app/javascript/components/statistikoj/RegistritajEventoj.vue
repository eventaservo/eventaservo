<template>
  <div id="registered_events"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "RegistritajEventoj",
  mounted () {
    axios.get("/statistikoj.json", {
      params: { q: "registritaj_eventoj" }
    }).then(response => {
      this.diagramo(response.data.landoj, response.data.kvantoj)
    })
  },
  methods: {
    diagramo (landoj, kvantoj) {
      Highcharts.chart("registered_events", {
        colors: ["#28a745"],
        chart: {
          type: "column"
        },
        title: {
          text: "Registritaj eventoj - 15 plej popularaj landoj"
        },
        subtitle: {
          text: "Okazintaj kaj okazontaj"
        },
        legend: {
          enabled: false
        },
        xAxis: {
          categories: landoj,
          crosshair: true
        },
        yAxis: {
          min: 0,
          title: {
            text: "Eventoj"
          }
        },
        tooltip: {
          headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
          pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + '<td style="padding:0"><b>{point.y} eventoj</b></td></tr>',
          footerFormat: "</table>",
          shared: true,
          useHTML: true
        },
        plotOptions: {
          column: {
            pointPadding: 0,
            borderWidth: 0
          }
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
