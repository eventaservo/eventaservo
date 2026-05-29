import { Controller } from "@hotwired/stimulus"
import { Tooltip } from "bootstrap"

// Initializes Bootstrap 5 tooltips on elements with data-bs-toggle="tooltip"
// within the controller's scope. Automatically re-initializes when the
// DOM content changes (e.g. after AJAX updates).
//
// Usage:
//   <div data-controller="tooltip">
//     <i data-bs-toggle="tooltip" title="Help text"></i>
//   </div>
export default class extends Controller {
  // Initializes tooltips and starts observing for DOM changes.
  connect() {
    this.#initTooltips()
    this._observer = new MutationObserver(() => this.#initTooltips())
    this._observer.observe(this.element, { childList: true, subtree: true })
  }

  // Stops the observer and disposes of all tooltips to prevent memory leaks.
  disconnect() {
    this._observer?.disconnect()
    this.element.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
      Tooltip.getInstance(el)?.dispose()
    })
  }

  // Finds and activates all tooltip-enabled elements inside this controller.
  #initTooltips() {
    this.element.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
      if (!Tooltip.getInstance(el)) new Tooltip(el)
    })
  }
}
