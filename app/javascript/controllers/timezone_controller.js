import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="timezone"
export default class extends Controller {
  static targets = ["timezoneSelect"]

  connect() {
    new SlimSelect({
      select: this.timezoneSelectTarget,
      settings: {
        searchPlaceholder: "Serĉi...",
        searchText: "Neniu trafo",
      }
    })
  }
}
