<template>
  <div>
    <h4 class="text-center"><i class="fas fa-handshake fg-color-info"></i> PARTNERAJ ORGANIZOJ</h4>
    <div class="row">
      <div v-for="o in organizoj" class="col-12 col-md-6 mb-2">
        <a v-bind:href="o.url" class="card-link">
          <div class="card">
            <div class="card-header bg-info fg-color-white text-center">
              {{ o.name }}
            </div>
            <div class="card-body">
              <img v-bind:src="o.logo_url" style="float: left; max-width: 64px;" class="mr-2">
              {{ o.description }}
            </div>
          </div>
        </a>
      </div>
    </div>
  </div>
</template>

<script>

import axios from "axios"

export default {
  name: "Partneroj",
  data () {
    return {
      organizoj: null
    }
  },
  mounted () {
    axios.get("/o/partneroj.json").then(response => {
      this.organizoj = response.data
    })
  }
}
</script>

<style scoped>

</style>
