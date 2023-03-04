<template>
  <div>
    <div class="card mb-2">
      <img :src="imageUrl" class="card-img-top" style="max-height: 200px" />
      <div class="card-body">
        <p class="card-title">
          <a :href="video.url">{{ video.title }}</a>
        </p>

        <p class="card-text small">
          {{ video.description }}
          <a v-if="forigebla" :href="'/video/' + video.id + '/forigi'">
            <i class="fas fa-trash fg-color-red"></i>
          </a>
        </p>
      </div>
      <div v-if="evento" class="card-footer small">
        {{
          this.$moment(evento.date_start, 'YYYY-MM-DD')
            .format('MMMM YYYY')
            .toLowerCase()
        }}
        <br />
        <a :href="'/e/' + evento.short_url" class="card-link">
          {{ evento.title }}
        </a>
        <div v-if="organizoj">
          <a
            v-for="organizo in organizoj"
            :href="'/o/' + organizo[1]"
            class="fg-color-blueLight"
            >{{ organizo[0] }}<br></a
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'VideoKarto',
  props: {
    video: {
      type: Object,
      required: true,
    },
    imageUrl: {
      type: String,
      required: true,
    },
    evento: {
      type: Object,
      required: false,
      default: null,
    },
    organizoj: {
      type: Array,
      required: false,
      default: null,
    },
    forigebla: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
}
</script>
