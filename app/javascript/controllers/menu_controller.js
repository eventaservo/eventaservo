import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="menu"
export default class extends Controller {
  static targets = ["button", "panel", "item"]
  static values = {
    open: { type: Boolean, default: false },
    activeClass: { type: String, default: "show" },
    closeOnEsc: { type: Boolean, default: true },
    closeOnClickOutside: { type: Boolean, default: true }
  }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleDocumentKeydown = this.handleDocumentKeydown.bind(this)
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handlePanelClick = this.handlePanelClick.bind(this)

    this.element.addEventListener("keydown", this.handleKeydown)
    this.element.addEventListener("click", this.handlePanelClick)
    document.addEventListener("keydown", this.handleDocumentKeydown, true)
    document.addEventListener("click", this.handleClickOutside)

    this.setupAccessibility()
    this.updateState()
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown)
    this.element.removeEventListener("click", this.handlePanelClick)
    document.removeEventListener("keydown", this.handleDocumentKeydown, true)
    document.removeEventListener("click", this.handleClickOutside)
  }

  setupAccessibility() {
    if (this.hasButtonTarget) {
      if (!this.buttonTarget.hasAttribute("aria-haspopup")) {
        this.buttonTarget.setAttribute("aria-haspopup", "true")
      }
      if (this.hasPanelTarget && this.panelTarget.id && !this.buttonTarget.hasAttribute("aria-controls")) {
        this.buttonTarget.setAttribute("aria-controls", this.panelTarget.id)
      }
    }

    if (this.hasPanelTarget) {
      if (!this.panelTarget.hasAttribute("role")) {
        this.panelTarget.setAttribute("role", "menu")
      }

      this.menuItems.forEach((el) => {
        if (!el.hasAttribute("role")) {
          el.setAttribute("role", "menuitem")
        }
        if (!el.hasAttribute("tabindex")) {
          el.setAttribute("tabindex", "-1")
        }
      })
    }
  }

  get menuItems() {
    if (!this.hasPanelTarget) {
      return []
    }

    const candidates = this.hasItemTarget
      ? this.itemTargets
      : Array.from(this.panelTarget.querySelectorAll("[role='menuitem'], a[href], button:not([disabled])"))

    return candidates.filter((el) => !el.disabled && el.getAttribute("aria-disabled") !== "true")
  }

  toggle(event) {
    if (event) {
      event.preventDefault()
    }
    this.openValue = !this.openValue
    this.updateState()
  }

  open(event) {
    if (event) {
      event.preventDefault()
    }
    this.openValue = true
    this.updateState()
  }

  close() {
    this.openValue = false
    this.updateState()
  }

  focusFirstItem() {
    if (!this.openValue) {
      this.openValue = true
    }
    this.updateState()
    if (this.hasPanelTarget) {
      void this.panelTarget.offsetHeight
    }
    const items = this.menuItems
    if (items.length > 0) {
      items[0].focus()
    }
  }

  focusLastItem() {
    if (!this.openValue) {
      this.openValue = true
    }
    this.updateState()
    if (this.hasPanelTarget) {
      void this.panelTarget.offsetHeight
    }
    const items = this.menuItems
    if (items.length > 0) {
      items[items.length - 1].focus()
    }
  }

  openValueChanged() {
    this.updateState()
  }

  updateState() {
    const isOpen = this.openValue

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", isOpen.toString())
    }

    if (this.hasPanelTarget) {
      const panel = this.panelTarget
      const hiddenClass = panel.dataset.menuHiddenClass || "tw:hidden"

      if (isOpen) {
        if (this.activeClassValue) {
          panel.classList.add(this.activeClassValue)
        }
        panel.classList.remove(hiddenClass)
      } else {
        if (this.activeClassValue) {
          panel.classList.remove(this.activeClassValue)
        }
        if (panel.dataset.menuHiddenClass) {
          panel.classList.add(panel.dataset.menuHiddenClass)
        }
      }
    }

    if (this.renderedOpen !== isOpen) {
      this.renderedOpen = isOpen
      this.dispatch(isOpen ? "opened" : "closed")
    }
  }

  handleDocumentKeydown(event) {
    if (this.closeOnEscValue && this.openValue && (event.key === "Escape" || event.key === "Esc")) {
      event.preventDefault()
      event.stopPropagation()
      this.close()
      if (this.hasButtonTarget) {
        this.buttonTarget.focus()
      }
    }
  }

  handleKeydown(event) {
    const isTriggerFocused = this.hasButtonTarget && (event.target === this.buttonTarget || this.buttonTarget.contains(event.target))

    if (isTriggerFocused) {
      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.focusFirstItem()
        return
      }
      if (event.key === "ArrowUp") {
        event.preventDefault()
        this.focusLastItem()
        return
      }
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault()
        this.toggle()
        if (this.openValue) {
          this.focusFirstItem()
        }
        return
      }
    }

    if (!this.openValue) {
      return
    }

    const items = this.menuItems
    if (items.length === 0) {
      if (event.key === "Tab") {
        this.close()
      }
      return
    }

    const currentIndex = items.indexOf(document.activeElement)

    if (event.key === "ArrowDown") {
      event.preventDefault()
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + 1) % items.length
      items[nextIndex].focus()
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      const prevIndex = currentIndex <= 0 ? items.length - 1 : currentIndex - 1
      items[prevIndex].focus()
    } else if (event.key === "Home") {
      event.preventDefault()
      items[0].focus()
    } else if (event.key === "End") {
      event.preventDefault()
      items[items.length - 1].focus()
    } else if (event.key === "Tab") {
      this.close()
    }
  }

  handlePanelClick(event) {
    if (!this.openValue || !this.hasPanelTarget || !this.panelTarget.contains(event.target)) {
      return
    }

    const item = event.target.closest("[role='menuitem'], a[href], button:not([disabled])")
    if (item && this.panelTarget.contains(item) && item.getAttribute("aria-disabled") !== "true") {
      this.close()
    }
  }

  handleClickOutside(event) {
    if (this.closeOnClickOutsideValue && this.openValue && !this.element.contains(event.target)) {
      this.close()
    }
  }
}
