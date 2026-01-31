import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="event--form"
export default class extends Controller {
  static targets = ["organizations", "submit"]

  connect() {
    // Only initialize SlimSelect if organizations target exists
    // This prevents errors when user has no organizations
    if (this.hasOrganizationsTarget) {
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

  submit(event) {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Registras...'
    }
  }
}
