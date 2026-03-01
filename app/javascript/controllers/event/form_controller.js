import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Connects to data-controller="event--form"
export default class extends Controller {
  static targets = ["organizations", "endDateHidden", "endDateInput", "timeStart", "timeEnd"]

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

  syncEndDate(event) {
    const { iso, dmy } = event.detail
    if (this.hasEndDateHiddenTarget) {
      this.endDateHiddenTarget.value = dmy
    }
    if (this.hasEndDateInputTarget) {
      this.endDateInputTarget.value = iso
    }
    this.#focusIfForward(this.timeStartTarget, event.target)
  }

  focusEndTime(event) {
    this.#focusIfForward(this.timeEndTarget, event.target)
  }

  // Only auto-focus the target if the user is navigating forward (Tab / click)
  // or completing a calendar popup selection (focus stays on the date input).
  // When going backward (Shift+Tab) the browser already placed focus on a
  // different field — we must not steal it.
  #focusIfForward(target, source) {
    if (!target) return
    requestAnimationFrame(() => {
      const active = document.activeElement
      if (!active || active === document.body || active === target || source?.contains(active)) {
        target.focus()
      }
    })
  }
}
