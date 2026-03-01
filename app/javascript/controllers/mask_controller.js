import { Controller } from "@hotwired/stimulus"
import IMask from "imask"

// Applies input masks using imask.js.
// Usage: data-controller="mask" data-mask-pattern-value="date|time|birthday"
export default class extends Controller {
  static values = { pattern: String }

  connect() {
    const config = this.maskConfig()
    if (config) {
      this.mask = IMask(this.element, config)
    }

    if (this.patternValue === "time") {
      this.selectOnFocus = () => this.element.setSelectionRange(0, 5)
      this.element.addEventListener("focus", this.selectOnFocus)
    }
  }

  disconnect() {
    if (this.mask) {
      this.mask.destroy()
    }
    if (this.selectOnFocus) {
      this.element.removeEventListener("focus", this.selectOnFocus)
    }
  }

  maskConfig() {
    switch (this.patternValue) {
      case "date":
        return { mask: "00{/}00{/}0000", lazy: false, placeholderChar: "_", eager: true }
      case "time":
        return { mask: "00{:}00", lazy: false, placeholderChar: "_", eager: true }
      case "birthday":
        return { mask: "00{/}00{/}0000", lazy: true, eager: true, overwrite: true }
      default:
        return null
    }
  }
}
