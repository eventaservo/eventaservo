import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["button", "content", "icon"]
  static values = {
    open: { type: Boolean, default: false },
    activeClass: { type: String, default: "show" },
    closeOnEsc: { type: Boolean, default: true },
    closeOnClickOutside: { type: Boolean, default: true },
    breakpoint: { type: Number, default: 992 }
  }

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleResize = this.handleResize.bind(this)

    window.addEventListener("resize", this.handleResize)
    document.addEventListener("keydown", this.handleKeydown)
    document.addEventListener("click", this.handleClickOutside)

    this.initialized = false
    this.updateState()
    this.initialized = true
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
    document.removeEventListener("keydown", this.handleKeydown)
    document.removeEventListener("click", this.handleClickOutside)
    this.clearAnimation()
  }

  clearAnimation() {
    if (this.animTimer) {
      clearTimeout(this.animTimer)
      this.animTimer = null
    }
  }

  toggle(event) {
    if (event) {
      event.preventDefault()
    }
    this.openValue = !this.openValue
  }

  open() {
    this.openValue = true
  }

  close() {
    this.openValue = false
  }

  openValueChanged() {
    this.updateState()
  }

  updateState() {
    const isOpen = this.openValue
    this.clearAnimation()

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", isOpen.toString())
    }

    if (this.hasIconTarget) {
      if (isOpen) {
        this.iconTarget.classList.remove("fa-bars")
        this.iconTarget.classList.add("fa-times")
      } else {
        this.iconTarget.classList.remove("fa-times")
        this.iconTarget.classList.add("fa-bars")
      }
    }

    if (this.hasContentTarget) {
      const content = this.contentTarget

      if (!this.initialized) {
        // Immediate update on initial page connect without animation
        if (isOpen) {
          if (this.activeClassValue) {
            content.classList.add(this.activeClassValue)
          }
          content.classList.remove("tw:hidden")
        } else {
          if (this.activeClassValue) {
            content.classList.remove(this.activeClassValue)
          }
          if (content.dataset.toggleHiddenClass) {
            content.classList.add(content.dataset.toggleHiddenClass)
          }
        }
      } else if (isOpen) {
        // Smooth slide-down & fade-in animation
        if (this.activeClassValue) {
          content.classList.add(this.activeClassValue)
        }
        content.classList.remove("tw:hidden")
        content.style.overflow = "hidden"
        content.style.maxHeight = "0px"
        content.style.opacity = "0"
        content.style.transition = "max-height 250ms cubic-bezier(0.4, 0, 0.2, 1), opacity 200ms ease-out"

        requestAnimationFrame(() => {
          content.style.maxHeight = `${content.scrollHeight}px`
          content.style.opacity = "1"
        })

        this.animTimer = setTimeout(() => {
          if (this.openValue) {
            content.style.maxHeight = ""
            content.style.opacity = ""
            content.style.overflow = ""
            content.style.transition = ""
          }
        }, 260)
      } else {
        // Smooth slide-up & fade-out animation
        content.style.overflow = "hidden"
        content.style.maxHeight = `${content.scrollHeight}px`
        content.style.opacity = "1"
        content.style.transition = "max-height 220ms cubic-bezier(0.4, 0, 0.2, 1), opacity 180ms ease-in"

        requestAnimationFrame(() => {
          content.style.maxHeight = "0px"
          content.style.opacity = "0"
        })

        this.animTimer = setTimeout(() => {
          if (!this.openValue) {
            if (this.activeClassValue) {
              content.classList.remove(this.activeClassValue)
            }
            if (content.dataset.toggleHiddenClass) {
              content.classList.add(content.dataset.toggleHiddenClass)
            }
            content.style.maxHeight = ""
            content.style.opacity = ""
            content.style.overflow = ""
            content.style.transition = ""
          }
        }, 230)
      }
    }

    this.dispatch(isOpen ? "opened" : "closed")
  }

  handleKeydown(event) {
    if (this.closeOnEscValue && this.openValue && (event.key === "Escape" || event.key === "Esc")) {
      event.preventDefault()
      this.close()
      if (this.hasButtonTarget) {
        this.buttonTarget.focus()
      }
    }
  }

  handleClickOutside(event) {
    if (this.closeOnClickOutsideValue && this.openValue && !this.element.contains(event.target)) {
      this.close()
    }
  }

  handleResize() {
    if (window.innerWidth >= this.breakpointValue) {
      this.clearAnimation()
      if (this.hasContentTarget) {
        this.contentTarget.style.maxHeight = ""
        this.contentTarget.style.opacity = ""
        this.contentTarget.style.overflow = ""
        this.contentTarget.style.transition = ""
      }
      if (this.openValue) {
        this.close()
      }
    }
  }
}
