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

    const isFixed = window.getComputedStyle(this.element).position === "fixed"

    if (isFixed) {
      // Floating banners (flash messages): fade out without moving the page layout
      this.element.classList.add("tw:opacity-0")
      setTimeout(() => {
        this.element.remove()
        this.dispatch("dismissed")
      }, 300)
    } else {
      // Inline banners: smoothly shrink height and margin to avoid abrupt jumps
      this.element.style.transition = "opacity 300ms ease, max-height 300ms ease, margin 300ms ease, padding 300ms ease"
      this.element.style.maxHeight = `${this.element.scrollHeight}px`
      this.element.style.overflow = "hidden"

      requestAnimationFrame(() => {
        this.element.classList.add("tw:opacity-0")
        this.element.style.maxHeight = "0px"
        this.element.style.marginTop = "0px"
        this.element.style.marginBottom = "0px"
        this.element.style.paddingTop = "0px"
        this.element.style.paddingBottom = "0px"
      })

      setTimeout(() => {
        this.element.remove()
        this.dispatch("dismissed")
      }, 320)
    }
  }
}
