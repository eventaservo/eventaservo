import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="video"
export default class extends Controller {
  static targets = ['url', 'title', 'description', 'thumbnail']

  connect() {}

  fetchData() {
    const apikey = this.data.get('apikey')
    const url = this.urlTarget.value
    const youtube_url = url.match(
      /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/
    )

    if (youtube_url) {
      this.thumbnailTarget.classList.add('d-none')
      this.thumbnailTarget.value = ''

      const youtube_id = youtube_url[1]
      const apiUrl = `https://www.googleapis.com/youtube/v3/videos?id=${youtube_id}&key=${apikey}&part=snippet`

      fetch(apiUrl)
        .then((response) => response.json())
        .then((data) => {
          const snippet = data.items[0].snippet
          this.titleTarget.value = snippet.title
          this.descriptionTarget.value = snippet.description.substring(0, 100)
        })
    } else {
      window.b = this.thumbnailTarget
      this.thumbnailTarget.classList.remove('d-none')
      this.thumbnailTarget.value = ''
    }
  }
}
