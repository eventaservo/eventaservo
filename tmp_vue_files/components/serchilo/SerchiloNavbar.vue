<template>
        <input
          type="search"
          class="form-control form-control-sm"
          placeholder="Serĉi..."
          @keypress.enter="alidirektas"
          @keyup="alidirektas"
          v-model.trim="teksto"
        />
</template>

<script>
export default {
  name: 'SerchiloNavbar',
  data() {
    return {
      teksto: '',
      timer: null
    }
  },
  methods: {
    alidirektas() {
      if (this.timer) {
        clearTimeout(this.timer)
        this.timer = null
      }

      this.timer = setTimeout(() => {
        window.location.href = `/serchilo?query=${this.teksto}`
      }, 3000)
    },
  },
}
</script>

<style scoped></style>
