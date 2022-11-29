<template>
  <div>
    <div class="box-white">
      <div class="d-flex">
        <h1>Serĉilo</h1>

        <span
          v-if="loading"
          class="ml-3 mt-2 spinner-border text-success"
          role="status"
        >
          <span class="sr-only">Loading...</span>
        </span>
      </div>

      <form>
        <div class="row">
          <div class="col-12 col-md-9">
            <div class="input-group">
              <input
                v-model.trim="serchteksto"
                autofocus
                class="form-control"
                placeholder="Serĉi eventojn aŭ organizojn... (minimume 3 signoj)"
                type="text"
                @keyup="serchas"
                @keydown.enter.prevent="serchas"
              />
              <div class="input-group-append">
                <button
                  class="btn btn-primary"
                  type="button"
                  @click.prevent="serchas"
                >
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
          </div>
          <div class="col-12 col-md-3">
            <div class="d-sm-flex justify-content-around flex-md-column">
              <div class="custom-control custom-switch">
                <input
                  id="pasintaj"
                  v-model="pasintaj"
                  autocomplete="off"
                  class="custom-control-input"
                  type="checkbox"
                  @change="serchas"
                />
                <label class="custom-control-label" for="pasintaj"
                  >Pasintaj</label
                >
              </div>
              <div class="custom-control custom-switch">
                <input
                  id="nuligitaj"
                  v-model="nuligitaj"
                  autocomplete="off"
                  class="custom-control-input"
                  type="checkbox"
                  @change="serchas"
                />
                <label class="custom-control-label" for="nuligitaj"
                  >Nuligitaj</label
                >
              </div>
            </div>
          </div>
        </div>
      </form>
    </div>

    <div v-if="serchteksto.length > 2" id="organizRezultoj" class="box-white">
      <div class="box-header">Organizoj</div>
      <div v-if="rezulto.organizKvanto > 0">
        <h5>
          {{ rezulto.organizKvanto }}
          <span v-if="rezulto.organizKvanto === 1">organizo trovita</span>
          <span v-else>organizoj trovitaj</span>
        </h5>
        <div class="table-responsive">
          <table class="table table-sm table-hover">
            <thead>
              <tr>
                <th scope="col">Nomo</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="organizo in rezulto.organizoj"
                :key="organizo.id"
                class="small pointer"
                @click="vidiOrganizon(organizo.mallongilo)"
              >
                <td v-html="organizo.nomo"></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else>Neniu organizo trovita</div>
    </div>

    <div v-if="serchteksto.length > 2" id="eventRezultoj" class="box-white">
      <div class="box-header">Eventoj</div>
      <div v-if="rezulto.eventKvanto > 0">
        <h5>
          {{ rezulto.eventKvanto }}
          <span v-if="rezulto.eventKvanto === 1">evento trovita</span>
          <span v-else>eventoj trovitaj</span>
        </h5>
        <div class="table-responsive">
          <table class="table table-sm table-hover">
            <thead>
              <tr>
                <th scope="col">Titolo</th>
                <th scope="col">Urbo</th>
                <th scope="col">Dato</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="evento in rezulto.eventoj"
                :key="evento.id"
                :class="evento.klass"
                class="small pointer"
                @click="vidiEventon(evento.ligilo)"
              >
                <td
                  :class="{ nuligita: evento.nuligita }"
                  v-html="evento.titolo"
                ></td>
                <td
                  :class="{ nuligita: evento.nuligita }"
                  v-html="evento.city"
                ></td>
                <td :class="{ nuligita: evento.nuligita }">
                  {{ evento.dato }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else>Neniu evento trovita</div>
    </div>

    <div v-if="serchteksto.length > 2" id="uzantRezultoj" class="box-white">
      <div class="box-header">Uzantoj</div>
      <div v-if="rezulto.uzantoj && rezulto.uzantoj.length > 0">
        <h5>
          {{ rezulto.uzantoj.length }}
          <span v-if="rezulto.uzantoj.length === 1">uzanto trovita</span>
          <span v-else>uzantoj trovitaj</span>
        </h5>
        <div class="table-responsive">
          <table class="table table-sm table-hover">
            <thead>
              <tr>
                <th scope="col">Nomo</th>
                <th scope="col">Lando</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="uzanto in rezulto.uzantoj"
                :key="uzanto.uzantnomo"
                class="small pointer"
                @click="vidiUzanton(uzanto.uzantnomo)"
              >
                <td v-html="uzanto.nomo"></td>
                <td>
                  {{ uzanto.lando }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else>Neniu uzanto trovita</div>
    </div>

    <div v-if="serchteksto.length > 2" id="videoRezultoj" class="box-white">
      <div class="box-header">Registritaj prezentoj</div>
      <div v-if="rezulto.videoj && rezulto.videoj.length > 0">
        <h5>
          {{ rezulto.videoj.length }}
          <span v-if="rezulto.videoj.length === 1">registrita prezento trovita</span>
          <span v-else>registritaj prezentoj trovitaj</span>
        </h5>
        <div class="table-responsive">
          <table class="table table-sm table-hover">
            <thead>
            <tr>
              <th scope="col">Titolo</th>
              <th scope="col">Evento</th>
              <th scope="col">Dato</th>
            </tr>
            </thead>
            <tbody>
            <tr
              v-for="video in rezulto.videoj"
              :key="video.id"
              class="small pointer"
              @click="vidiVideon(video.url)"
            >
              <td v-html="video.titolo"></td>
              <td v-html="video.evento"></td>
              <td v-html="video.dato"></td>

            </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else>Neniu registrita prezento trovita</div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'Serchilo',
  data() {
    return {
      serchteksto: '',
      pasintaj: false,
      nuligitaj: false,
      loading: false,
      timer: null,
      rezulto: {},
    }
  },
  mounted() {
    const q = new URLSearchParams(window.location.search)
    if (q.get('query')) {
      this.serchteksto = q.get('query')
      this.serchas()
    }
  },
  methods: {
    serchas() {
      if (this.serchteksto.length < 3) {
        return false
      }

      this.loading = true

      if (this.timer) {
        clearTimeout(this.timer)
        this.timer = null
      }

      this.timer = setTimeout(() => {
        axios
          .get('/search.json', {
            params: {
              query: this.serchteksto,
              pasintaj: this.pasintaj,
              nuligitaj: this.nuligitaj,
            },
          })
          .then((response) => {
            this.rezulto = response.data
            console.log(response.data)
            this.loading = false
          })
      }, 800)
    },
    vidiEventon(ligilo) {
      window.location.href = `/e/${ligilo}`
    },
    vidiOrganizon(mallongilo) {
      window.location.href = `/o/${mallongilo}`
    },
    vidiUzanton(uzantnomo) {
      window.location.href = `/uzanto/${uzantnomo}`
    },
    vidiVideon(url) {
      window.location.href = `${url}`
    },
  },
}
</script>

<style scoped>
.pointer {
  cursor: pointer;
}

.nuligita {
  color: red;
  text-decoration: line-through;
}
</style>
