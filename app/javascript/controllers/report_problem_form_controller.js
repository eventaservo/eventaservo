import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report-problem-form"
export default class extends Controller {
  static targets = ["name", "message"]

  connect() {
    $(this.element).on('shown.bs.modal', this.handleModalShown.bind(this))
  }

  disconnect() {
    $(this.element).off('shown.bs.modal', this.handleModalShown.bind(this))
  }

  handleModalShown(event) {
    if (this.hasNameTarget && this.nameTarget.value === "") {
      this.nameTarget.focus()
    } else if (this.hasMessageTarget) {
      this.messageTarget.focus()
    }
  }
}
