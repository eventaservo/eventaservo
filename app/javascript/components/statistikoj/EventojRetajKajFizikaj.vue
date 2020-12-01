<template>
  <div id="eventoj_retaj_kaj_fizikaj"></div>
</template>

<script>
/* global Highcharts */

import axios from "axios"

export default {
  name: "EventojRetajKajFizikaj",
  mounted () {
    axios.get("/statistikoj.json", {
      params: { q: "eventoj_retaj_kaj_fizikaj" }
    }).then(response => {
      this.diagramo(response.data.x_axis, response.data.eventoj)
    })
  },
  methods: {
    diagramo (monatoj, eventoj) {
      Highcharts.chart("eventoj_retaj_kaj_fizikaj", {
        colors: ["#9898ec", "#28a745"],
        credits: {
          enabled: false
        },
        chart: {
          type: "column"
        },
        title: {
          text: "Novaj eventoj laŭ monatoj"
        },
        subtitle: {
          text: 'Retaj kaj fizikaj'
        },
        xAxis: {
          categories: monatoj,
          title: {
            enabled: false
          }
        },
        yAxis: {
          title: {
            text: "Novaj eventoj"
          }
        },
        tooltip: {
          pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y:.0f} novaj eventoj</b><br/>',
          shared: true
        },
        plotOptions: {
          column: {
            stacking: 'normal',
            dataLabels: {
              enabled: true
            }
          },
          area: {
            stacking: "normal",
            lineWidth: 1,
            marker: {
              enabled: false,
              hover: { enabled: false }
            }
          }
        },
        series: eventoj
      })
    }
  }
}
</script>

<style scoped>

</style>
