<template>
  <div id="tagoj"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "LauTago",
  mounted () {
    axios.get("/admin/analizado_lau_tago.json").then(response => {
      console.log(response.data)
      this.diagramo(response.data.tagoj)
    })
  },
  methods: {
    diagramo (tagoj) {
      Highcharts.chart("tagoj", {
        credits: {
          enabled: false
        },
        chart: {
          type: "spline"
        },
        title: {
          text: "Laŭ tago"
        },
        xAxis: {
          type: "datetime",
          labels: {
            enabled: false
          }
        },
        yAxis: {
          title: {
            text: "Vizitantoj"
          }
        },
        legend: {
          enabled: false
        },
        tooltip: {
          pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y:,.0f}</b><br/>',
          shared: true
        },
        plotOptions: {
          spline: {
            marker: {
              enabled: false
            }
          }
        },
        series: [
          {
            name: "Vizitantoj",
            data: tagoj
          }
        ]
      })
    }
  }
}
</script>

<style scoped>

</style>
