<template>
        <input
          type="search"
          class="form-control form-control-sm"
          placeholder="Serĉi..."
          @keypress.enter="alidirektas"
          v-model.trim="teksto"
        />
</template>

<script>
export default {
  name: 'SerchiloNavbar',
  data() {
    return {
      teksto: '',
    }
  },
  methods: {
    alidirektas() {
      console.log('ALIDIREKTAS')
      window.location.href = `/serchilo?query=${this.teksto}`
    },
  },
}
</script>

<style scoped></style>
