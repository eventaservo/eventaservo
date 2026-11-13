import { Controller } from "@hotwired/stimulus"

const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  "[tabindex]:not([tabindex='-1'])",
  "[contenteditable='true']"
].join(", ")

// Connects to data-controller="dialog"
export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    openOnConnect: { type: Boolean, default: false },
    autoFocus: { type: Boolean, default: true }
  }

  connect() {
    this.previousActiveElement = null
    this.skipFocusRestore = false

    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.handleBeforeCache = this.handleBeforeCache.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleClose = this.handleClose.bind(this)

    document.addEventListener("click", this.handleDocumentClick)
    document.addEventListener("turbo:before-cache", this.handleBeforeCache)

    const dialog = this.dialogElement
    if (dialog) {
      dialog.addEventListener("keydown", this.handleKeydown)
      dialog.addEventListener("close", this.handleClose)
    }

    if (this.openOnConnectValue) {
      this.showDialog()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick)
    document.removeEventListener("turbo:before-cache", this.handleBeforeCache)

    const dialog = this.dialogElement
    if (dialog) {
      dialog.removeEventListener("keydown", this.handleKeydown)
      dialog.removeEventListener("close", this.handleClose)
    }
  }

  get dialogElement() {
    if (this.hasDialogTarget) return this.dialogTarget

    return this.element
  }

  get focusableElements() {
    const dialog = this.dialogElement
    if (!dialog) return []

    return Array.from(dialog.querySelectorAll(FOCUSABLE_SELECTOR)).filter((el) => {
      if (el.disabled || el.getAttribute("aria-hidden") === "true") return false
      if (el.offsetParent === null && getComputedStyle(el).position !== "fixed") return false

      return true
    })
  }

  open(event) {
    event?.preventDefault()
    this.showDialog(event?.currentTarget)
  }

  close(event) {
    event?.preventDefault()
    this.hideDialog()
  }

  backdropClose(event) {
    const dialog = this.dialogElement
    if (!dialog || event.target !== dialog) return
    if (event.clientX === 0 && event.clientY === 0) return

    const rect = dialog.getBoundingClientRect()
    const clickedInside =
      event.clientX >= rect.left &&
      event.clientX <= rect.right &&
      event.clientY >= rect.top &&
      event.clientY <= rect.bottom

    if (!clickedInside) {
      this.hideDialog()
    }
  }

  handleDocumentClick(event) {
    const dialog = this.dialogElement
    if (!dialog || !dialog.id) return

    const trigger = event.target.closest("[data-dialog-open]")
    if (!trigger || trigger.dataset.dialogOpen !== dialog.id) return

    event.preventDefault()
    this.showDialog(trigger)
  }

  handleBeforeCache() {
    this.skipFocusRestore = true
    this.hideDialog()
  }

  handleClose() {
    const target = this.previousActiveElement
    const shouldRestore = !this.skipFocusRestore

    this.previousActiveElement = null
    this.skipFocusRestore = false

    if (shouldRestore && target && target.isConnected && typeof target.focus === "function") {
      target.focus()
    }
  }

  handleKeydown(event) {
    if (event.key !== "Tab") return

    const dialog = this.dialogElement
    if (!dialog?.open) return

    const focusable = this.focusableElements
    if (focusable.length === 0) {
      event.preventDefault()
      return
    }

    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    const active = document.activeElement
    const outsideOrDialog = active === dialog || !dialog.contains(active)

    if (event.shiftKey) {
      if (active === first || outsideOrDialog) {
        event.preventDefault()
        last.focus()
      }
    } else if (active === last || outsideOrDialog) {
      event.preventDefault()
      first.focus()
    }
  }

  showDialog(trigger = null) {
    const dialog = this.dialogElement
    if (!dialog || dialog.open) return

    this.previousActiveElement = trigger instanceof HTMLElement ? trigger : document.activeElement
    this.skipFocusRestore = false

    dialog.showModal()

    if (this.autoFocusValue) {
      const autofocusTarget = dialog.querySelector("[autofocus]")
      const initialTarget = autofocusTarget || this.focusableElements[0] || dialog
      initialTarget.focus()
    } else {
      dialog.focus({ preventScroll: true })
    }

    this.dispatch("shown", { target: dialog, detail: { dialog } })
  }

  hideDialog() {
    const dialog = this.dialogElement
    if (dialog?.open) {
      dialog.close()
    }
  }
}
