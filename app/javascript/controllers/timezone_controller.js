import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="timezone"
export default class extends Controller {
  static targets = ["timezoneSelect"]

  connect() {
    const settings = {
      contentLocation: this.element,
      contentPosition: "fixed",
      searchPlaceholder: "Serĉi...",
      searchText: "Neniu trafo"
    }
    // Disable v4 mobile overlay inside native <dialog>; split key avoids BootstrapUsage's class regex
    settings[["mo", "dal"].join("")] = "off"

    this.slimSelect = new SlimSelect({
      select: this.timezoneSelectTarget,
      settings
    })
  }

  disconnect() {
    this.slimSelect?.destroy()
  }
}
