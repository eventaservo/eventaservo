<template>
  <div>
    <div v-if="logged">
      <div
        v-if="participant === 'false' && !elektilo"
        class="link-blue"
        @click="elektilo = !elektilo"
      >
        <h1>
          <i class="fas fa-user" />
        </h1>
        <span> Mi interesiĝas </span>
      </div>
      <div v-if="elektilo">
        Ĉu aperigi vian nomon en la listo de interesiĝantoj?
        <br />
        <a
          :href="ligilo + '?publika=jes'"
          class="btn btn-sm btn-success btn-block"
          >JES</a
        >
        <a :href="ligilo" class="btn btn-sm btn-danger btn-block">NE</a>
      </div>

      <a
        :href="ligilo"
        v-if="participant === 'true'"
        class="link-green"
      >
        <h1>
          <i class="fas fa-user-check" />
        </h1>
        <span>Mi interesiĝas!</span>
      </a>
    </div>
    <div v-else>
      <a href="/users/sign_in" class="font-weight-bold">Ensalutu</a>
      por informi vian partoprenon
    </div>
  </div>
</template>

<script>
export default {
  name: 'PartoprenantaButono',
  props: ['logged', 'ligilo', 'participant'],
  data() {
    return {
      elektilo: false,
    }
  },
}
</script>

<style scoped></style>
