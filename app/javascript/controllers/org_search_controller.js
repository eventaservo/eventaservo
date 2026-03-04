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
  // Debounces the search input. On Enter, blurs the field; otherwise
  // waits 500ms before sending the AJAX request.
  //
  // @param {KeyboardEvent} event
  search(event) {
    clearTimeout(this._timer)

    if (event.key === "Enter") {
      event.target.blur()
      return
    }

    this._timer = setTimeout(() => {
      $.get(this.element.action, $(this.element).serialize(), null, "script")
    }, 500)
  }

  // Clears any pending debounce timer on disconnect.
  disconnect() {
    clearTimeout(this._timer)
  }
}
