import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report-problem-form"
export default class extends Controller {
  static targets = ["name", "message"]

  connect() {
    this.handleDialogShown = this.handleDialogShown.bind(this)
    this.element.addEventListener("dialog:shown", this.handleDialogShown)
  }

  disconnect() {
    this.element.removeEventListener("dialog:shown", this.handleDialogShown)
  }

  handleDialogShown() {
    if (this.hasNameTarget && this.nameTarget.value === "") {
      this.nameTarget.focus()
    } else if (this.hasMessageTarget) {
      this.messageTarget.focus()
    }
  }
}
