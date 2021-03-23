<template>
  <div class="row">
    <div class="col-12 col-lg-8 offset-lg-2">
      <div class="box-white">
        <form
          :action="'/e/' + eventCode + '/nova_video'"
          enctype="multipart/form-data"
          method="post"
        >
          <div class="lead">Ligi registritan prezenton</div>
          <input :value="csrf" name="authenticity_token" type="hidden" />
          <div class="form-group">
            <label for="video_link">Adreso (URL) de la video</label>
            <input
              v-model="link"
              autofocus
              class="form-control form-control-sm"
              name="video_link"
              placeholder="ekz: https://www.youtube.com/watch?v=t7YPEKvmHvo"
              required
              type="text"
              @blur="fetchData"
            />
          </div>

          <div class="form-group">
            <label for="title">Titolo</label>

            <input
              v-model="title"
              :disabled="disabled"
              class="form-control form-control-sm"
              name="title"
              required
              type="text"
            />
          </div>
          <div class="form-group">
            <label for="priskribo">Priskribo</label>
            <textarea
              v-model="description"
              :disabled="disabled"
              class="form-control form-control-sm"
              name="description"
              required
              rows="5"
              maxlength="400"
            >
            </textarea>
            <small class="form-text text-muted">Maksimume 400 signoj.</small>
          </div>

          <div v-if="imageUpload" class="form-group">
            <div class="text-divider">Alŝulti bild-dosieron</div>
            <input
              id="bildo"
              accept="image/gif, image/jpeg, image/png"
              class="form-control-file"
              name="image"
              type="file"
            />
          </div>

          <div class="buttons-footer">
            <a :href="`/e/${eventCode}`" class="button-cancel">Ne registri</a>

            <button class="ml-2 btn btn-primary btn-sm" type="submit">
              <i class="fas fa-check"></i> Registri
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'VideoNova',
  props: ['eventCode', 'apikey'],
  data() {
    return {
      csrf: document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute('content'),
      description: '',
      disabled: false,
      imageUpload: false,
      link: '',
      title: '',
    }
  },
  methods: {
    fetchData() {
      const youtube_id = this.link.match(
        /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/
      )

      if (youtube_id != null) {
        this.disabled = true

        const apiUrl = `https://www.googleapis.com/youtube/v3/videos?id=${youtube_id[1]}&key=${this.apikey}&part=snippet`
        axios.get(apiUrl).then((response) => {
          console.log(response)
          if (response.data.items.length > 0) {
            this.title = response.data.items[0].snippet.title
            this.description = response.data.items[0].snippet.description.substring(0, 390)
          }
          this.disabled = false
        })
      } else {
        this.imageUpload = true
      }
    },
  },
}
</script>

<style scoped></style>
