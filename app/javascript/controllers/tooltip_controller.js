import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

// Initializes Bootstrap 4 tooltips on elements with data-toggle="tooltip"
// within the controller's scope.
//
// Usage:
//   <div data-controller="tooltip">
//     <i data-toggle="tooltip" title="Help text"></i>
//   </div>
export default class extends Controller {
  // Finds and activates all tooltip-enabled elements inside this controller.
  connect() {
    $(this.element).find('[data-toggle="tooltip"]').tooltip()
  }

  // Disposes of all tooltips to prevent memory leaks on page navigation.
  disconnect() {
    $(this.element).find('[data-toggle="tooltip"]').tooltip("dispose")
  }
}
