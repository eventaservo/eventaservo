import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="timezone"
export default class extends Controller {
  static targets = ["timezoneSelect"]

  connect() {
    this.slimSelect = new SlimSelect({
      select: this.timezoneSelectTarget,
      settings: {
        contentLocation: this.element,
        searchPlaceholder: "Serĉi...",
        searchText: "Neniu trafo",
      }
    })
  }

  disconnect() {
    this.slimSelect?.destroy()
  }
}
