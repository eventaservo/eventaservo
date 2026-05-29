import { Controller } from "@hotwired/stimulus"
import GLightbox from "glightbox"

// Initializes a GLightbox gallery on a container element.
// Usage: data-controller="lightbox"
// Links inside the container with class "glightbox" will be grouped into a gallery.
export default class extends Controller {
  connect() {
    this.lightbox = GLightbox({
      selector: ".glightbox",
      touchNavigation: true,
      loop: true,
    })
  }

  disconnect() {
    if (this.lightbox) {
      this.lightbox.destroy()
    }
  }
}
