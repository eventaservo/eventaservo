import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

// Debounces keyup events on the organization search form and triggers
// an AJAX request via jQuery (Rails UJS renders a JS response).
//
// Usage:
//   <form data-controller="org-search" data-action="keyup->org-search#search">
//     <input type="text" name="serchi">
//   </form>
export default class extends Controller {
  // Debounces the search input. On Enter, the form submits via
  // remote: true (Rails UJS) so we just cancel the pending timer to
  // avoid a duplicate request. Otherwise waits 500ms before sending.
  //
  // @param {KeyboardEvent} event
  search(event) {
    clearTimeout(this._timer)

    if (event.key === "Enter") return

    this._timer = setTimeout(() => {
      $.get(this.element.action, $(this.element).serialize(), null, "script")
    }, 500)
  }

  // Clears any pending debounce timer on disconnect.
  disconnect() {
    clearTimeout(this._timer)
  }
}
