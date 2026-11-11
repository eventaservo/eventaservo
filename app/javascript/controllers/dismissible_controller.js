import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dismissible"
export default class extends Controller {
  static values = {
    autoDismiss: Number
  }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    this.pauseAutoDismiss = this.pauseAutoDismiss.bind(this)
    this.resumeAutoDismiss = this.resumeAutoDismiss.bind(this)

    this.element.addEventListener("keydown", this.handleKeydown)

    if (this.hasAutoDismissValue && this.autoDismissValue > 0) {
      this.element.addEventListener("mouseenter", this.pauseAutoDismiss)
      this.element.addEventListener("mouseleave", this.resumeAutoDismiss)
      this.element.addEventListener("focusin", this.pauseAutoDismiss)
      this.element.addEventListener("focusout", this.resumeAutoDismiss)
      this.startTimer()
    }
  }

  disconnect() {
    this.clearTimer()
    this.element.removeEventListener("keydown", this.handleKeydown)
    this.element.removeEventListener("mouseenter", this.pauseAutoDismiss)
    this.element.removeEventListener("mouseleave", this.resumeAutoDismiss)
    this.element.removeEventListener("focusin", this.pauseAutoDismiss)
    this.element.removeEventListener("focusout", this.resumeAutoDismiss)
  }

  startTimer() {
    this.clearTimer()
    if (this.hasAutoDismissValue && this.autoDismissValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.autoDismissValue)
    }
  }

  clearTimer() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  pauseAutoDismiss() {
    this.clearTimer()
  }

  resumeAutoDismiss() {
    this.startTimer()
  }

  handleKeydown(event) {
    if (event.key === "Escape" || event.key === "Esc") {
      event.preventDefault()
      this.dismiss()
    }
  }

  dismiss() {
    this.clearTimer()

    // Safely release focus if active element is inside this dismissible banner
    if (this.element.contains(document.activeElement)) {
      document.activeElement.blur()
    }

    this.element.classList.add("tw:opacity-0")
    setTimeout(() => {
      this.element.remove()
      this.dispatch("dismissed")
    }, 300)
  }
}
