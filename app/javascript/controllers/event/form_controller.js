import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="event--form"
export default class extends Controller {
  static targets = ["organizations"]

  connect() {
    new SlimSelect({
      select: this.organizationsTarget,
      settings: {
        placeholderText: null,
        searchPlaceholder: "Serĉi...",
        searchText: "Neniu trafo",
      }
    })
  }
}
