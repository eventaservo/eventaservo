import { Controller } from "@hotwired/stimulus"
import SlimSelect from "slim-select"

// Manages the event creation/edit form.
//
// Responsibilities:
// - Initializes SlimSelect on the organizations multi-select
// - Syncs start date → end date via datepicker events
// - Toggles online/offline and universal/local form sections
// - Cross-validates site/email required fields
// - Validates at least one category tag is selected on submit
export default class extends Controller {
  static targets = [
    "organizations", "endDateHidden", "endDateInput", "timeStart", "timeEnd",
    "online", "universala", "onlineInfo", "timezone", "offlineInfo", "city",
    "site", "email", "tagsCategories"
  ]

  // Initializes SlimSelect for organizations (if present) and sets the
  // initial visibility of online/offline form sections.
  connect() {
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

    this.#applyOnlineState()
  }

  // Copies the start date into the end date fields (both ISO and DD/MM/YYYY)
  // when the start datepicker emits a "complete" event, then auto-focuses
  // the start time input.
  //
  // @param {CustomEvent} event - datepicker:complete event with { iso, dmy } detail
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

  // Auto-focuses the end time input when the end datepicker completes.
  //
  // @param {CustomEvent} event - datepicker:complete event
  focusEndTime(event) {
    this.#focusIfForward(this.timeEndTarget, event.target)
  }

  // Handles the "online event" checkbox change. When unchecked, resets the
  // universal checkbox and clears the city field. Then reapplies section
  // visibility.
  toggleOnline() {
    if (!this.onlineTarget.checked) {
      this.universalaTarget.checked = false
      this.cityTarget.value = ""
    }
    this.#applyOnlineState()
  }

  // Handles the "universal" (timezone-based) checkbox change. When checked,
  // sets city to "Reta"; when unchecked, clears city. Then reapplies
  // section visibility.
  toggleUniversala() {
    if (this.universalaTarget.checked) {
      this.cityTarget.value = "Reta"
    } else {
      this.cityTarget.value = ""
    }
    this.#applyOnlineState()
  }

  // Makes the site field optional when email has a value and vice-versa.
  // At least one of the two must be filled.
  crossValidateSiteEmail() {
    const siteHasValue = this.siteTarget.value.length > 0
    const emailHasValue = this.emailTarget.value.length > 0
    this.siteTarget.required = !emailHasValue
    this.emailTarget.required = !siteHasValue
  }

  // Prevents form submission if no category tag is selected.
  //
  // @param {Event} event - form submit event
  validateCategories(event) {
    if (this.tagsCategoriesTarget.querySelectorAll(".active").length === 0) {
      alert("Vi devas elekti almenaŭ unu specon")
      event.preventDefault()
      event.stopPropagation()

      // Rails UJS disables submit buttons via setTimeout(disableElement, 13).
      // Re-enable after that timer fires.
      const btn = this.element.querySelector("[type=submit]")
      if (btn) {
        setTimeout(() => {
          btn.disabled = false
        }, 50)
      }
    }
  }

  // Auto-focuses the target element only when the user is navigating forward
  // (Tab / click / calendar popup selection). Skips when going backward
  // (Shift+Tab) to avoid stealing focus.
  //
  // @param {HTMLElement} target - element to focus
  // @param {HTMLElement} source - element that triggered the event
  #focusIfForward(target, source) {
    if (!target) return
    requestAnimationFrame(() => {
      const active = document.activeElement
      if (!active || active === document.body || active === target || source?.contains(active)) {
        target.focus()
      }
    })
  }

  // Applies visibility rules for online/offline form sections based on
  // the current state of the online and universala checkboxes.
  //
  // - onlineInfo: visible when online is checked
  // - timezone: visible when both online and universala are checked
  // - offlineInfo: visible when offline, or online but not universala
  #applyOnlineState() {
    const online = this.onlineTarget.checked
    const universala = this.universalaTarget.checked

    this.#toggle(this.onlineInfoTarget, online)
    this.#toggle(this.timezoneTarget, online && universala)
    this.#toggle(this.offlineInfoTarget, !online || !universala)
  }

  // Shows or hides an element by setting its display style.
  //
  // @param {HTMLElement} element - DOM element to toggle
  // @param {boolean} visible - true to show, false to hide
  #toggle(element, visible) {
    element.style.display = visible ? "" : "none"
  }
}
