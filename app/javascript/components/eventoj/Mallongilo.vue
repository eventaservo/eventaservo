<template>
  <div>
    <div class="form-group">
      <label for="event_short_url">Mallonga ligilo (nedeviga)</label>
      <div class="input-group">
        <div class="input-group-prepend">
          <div class="input-group-text">https://eventaservo.org/e/</div>
        </div>
        <input type="text" class="form-control" id="event_short_url" name="event[short_url]"
               maxlength="32"
               :value="this.evento.short_url || this.evento.code"
               :class="{'is-invalid': !available}"
               v-on:keyup="cleanString"
               v-on:change="checkAvailability">
        <div class="invalid-feedback" v-if="!available">Mallongilo ne estas disponebla. Elektu alian.</div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

  export default {
    name: "Mallongilo",
    props: ['evento_rails'],
    data() {
      return {
        available: true,
        evento: ''
      }
    },
    created() {
      this.evento = JSON.parse(this.evento_rails);
    },
    methods: {
      cleanString(e) {
        e.target.value = e.target.value.replace(/\s/g, '');
      },
      checkAvailability(e) {
        if ((e.target.value == this.evento.code) || (e.target.value == JSON.parse(this.evento_rails).short_url)) {
          return true;
        }

        axios.get('/iloj/mallongilo_disponeblas',
          {
            params: {
              kodo: this.evento.code,
              mallongilo: e.target.value
            }
          })
          .then( (response) => {
            this.evento.short_url = e.target.value;
            this.available = response.data.disponeblo;
          })
      }
    }
  }
</script>

<style scoped>

</style>
