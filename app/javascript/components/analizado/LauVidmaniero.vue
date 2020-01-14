<template>
  <div id="vidmanieroj"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "LauVidmaniero",
  props: ["vidmanieroj", "x_axis"],
  mounted () {
    axios.get("/admin/analizado_lau_vidmaniero.json").then(response => {
      console.log(response.data)
      this.diagramo(response.data.vidmanieroj, response.data.x_axis)
    })
  },
  methods: {
    diagramo (vidmanieroj, x_axis) {
      Highcharts.chart("vidmanieroj", {
        credits: {
          enabled: false
        },
        chart: {
          type: "area"
        },
        title: {
          text: "Laŭ vidmaniero"
        },
        xAxis: {
          categories: x_axis,
          title: {
            enabled: false
          }
        },
        yAxis: {
          title: {
            text: "Percent"
          }
        },
        tooltip: {
          pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y:,.0f} vidoj)<br/>',
          shared: true
        },
        plotOptions: {
          area: {
            stacking: "percent",
            lineColor: "#ffffff",
            lineWidth: 1,
            marker: {
              enabled: false
            }
          }
        },
        series: vidmanieroj
      })
    }
  }
}
</script>

<style scoped>

</style>
