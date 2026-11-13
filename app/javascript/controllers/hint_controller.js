import { Controller } from "@hotwired/stimulus"

let nextHintId = 0
const VIEWPORT_PADDING = 8
const OFFSET = 8

// Connects to data-controller="hint"
export default class extends Controller {
  static values = {
    text: String,
    placement: { type: String, default: "top" }
  }

  connect() {
    this.tipId = `hint-bubble-${++nextHintId}`
    this.tipElement = null

    this.handleShow = this.show.bind(this)
    this.handleHide = this.hide.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)

    this.element.addEventListener("mouseenter", this.handleShow)
    this.element.addEventListener("mouseleave", this.handleHide)
    this.element.addEventListener("focusin", this.handleShow)
    this.element.addEventListener("focusout", this.handleHide)
    document.addEventListener("turbo:before-cache", this.handleHide)
  }

  disconnect() {
    this.element.removeEventListener("mouseenter", this.handleShow)
    this.element.removeEventListener("mouseleave", this.handleHide)
    this.element.removeEventListener("focusin", this.handleShow)
    this.element.removeEventListener("focusout", this.handleHide)
    document.removeEventListener("turbo:before-cache", this.handleHide)
    this.hide()
  }

  show() {
    const label = this.textValue?.trim()
    if (!label || this.tipElement) return

    const tip = document.createElement("div")
    tip.id = this.tipId
    tip.setAttribute("role", "tooltip")
    tip.className = [
      "tw:fixed tw:z-50 tw:w-max tw:max-w-xs tw:rounded-md",
      "tw:bg-esperanto-900 tw:px-2.5 tw:py-1.5 tw:text-xs tw:font-medium",
      "tw:leading-snug tw:text-white tw:text-center tw:shadow-lg tw:pointer-events-none"
    ].join(" ")

    const textSpan = document.createElement("span")
    textSpan.textContent = label
    tip.appendChild(textSpan)

    const arrow = document.createElement("span")
    arrow.setAttribute("aria-hidden", "true")
    arrow.className = "tw:absolute tw:h-2 tw:w-2 tw:rotate-45 tw:bg-esperanto-900"
    tip.appendChild(arrow)

    document.body.appendChild(tip)
    this.tipElement = tip
    this.arrowElement = arrow

    this.attachDescribedBy()
    this.positionTip()

    document.addEventListener("keydown", this.handleKeydown)
    window.addEventListener("scroll", this.handleHide, { passive: true, capture: true })
    window.addEventListener("resize", this.handleHide, { passive: true })
  }

  hide() {
    document.removeEventListener("keydown", this.handleKeydown)
    window.removeEventListener("scroll", this.handleHide, { capture: true })
    window.removeEventListener("resize", this.handleHide)

    this.detachDescribedBy()

    if (this.tipElement) {
      this.tipElement.remove()
      this.tipElement = null
      this.arrowElement = null
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }

  attachDescribedBy() {
    const existing = (this.element.getAttribute("aria-describedby") || "")
      .split(/\s+/)
      .filter(Boolean)

    if (!existing.includes(this.tipId)) {
      this.element.setAttribute("aria-describedby", [...existing, this.tipId].join(" "))
    }
  }

  detachDescribedBy() {
    const existing = (this.element.getAttribute("aria-describedby") || "")
      .split(/\s+/)
      .filter((id) => id && id !== this.tipId)

    if (existing.length > 0) {
      this.element.setAttribute("aria-describedby", existing.join(" "))
    } else {
      this.element.removeAttribute("aria-describedby")
    }
  }

  positionTip() {
    if (!this.tipElement) return

    const triggerRect = this.element.getBoundingClientRect()
    const tipRect = this.tipElement.getBoundingClientRect()
    const placement = this.resolvePlacement(triggerRect, tipRect)

    let top = 0
    let left = 0

    switch (placement) {
      case "bottom":
        top = triggerRect.bottom + OFFSET
        left = triggerRect.left + (triggerRect.width - tipRect.width) / 2
        break
      case "left":
        top = triggerRect.top + (triggerRect.height - tipRect.height) / 2
        left = triggerRect.left - tipRect.width - OFFSET
        break
      case "right":
        top = triggerRect.top + (triggerRect.height - tipRect.height) / 2
        left = triggerRect.right + OFFSET
        break
      default:
        top = triggerRect.top - tipRect.height - OFFSET
        left = triggerRect.left + (triggerRect.width - tipRect.width) / 2
        break
    }

    const maxLeft = Math.max(VIEWPORT_PADDING, window.innerWidth - tipRect.width - VIEWPORT_PADDING)
    const maxTop = Math.max(VIEWPORT_PADDING, window.innerHeight - tipRect.height - VIEWPORT_PADDING)

    const clampedLeft = Math.min(Math.max(VIEWPORT_PADDING, left), maxLeft)
    const clampedTop = Math.min(Math.max(VIEWPORT_PADDING, top), maxTop)

    this.tipElement.style.left = `${clampedLeft}px`
    this.tipElement.style.top = `${clampedTop}px`
    this.tipElement.dataset.placement = placement

    this.positionArrow(placement, triggerRect, tipRect, clampedLeft, clampedTop)
  }

  positionArrow(placement, triggerRect, tipRect, clampedLeft, clampedTop) {
    const arrow = this.arrowElement
    if (!arrow) return

    arrow.style.top = ""
    arrow.style.bottom = ""
    arrow.style.left = ""
    arrow.style.right = ""

    if (placement === "top" || placement === "bottom") {
      const triggerCenterX = triggerRect.left + triggerRect.width / 2
      const arrowLeft = Math.min(
        Math.max(8, triggerCenterX - clampedLeft - 4),
        Math.max(8, tipRect.width - 16)
      )
      arrow.style.left = `${arrowLeft}px`
      if (placement === "top") {
        arrow.style.bottom = "-4px"
      } else {
        arrow.style.top = "-4px"
      }
    } else {
      const triggerCenterY = triggerRect.top + triggerRect.height / 2
      const arrowTop = Math.min(
        Math.max(6, triggerCenterY - clampedTop - 4),
        Math.max(6, tipRect.height - 14)
      )
      arrow.style.top = `${arrowTop}px`
      if (placement === "left") {
        arrow.style.right = "-4px"
      } else {
        arrow.style.left = "-4px"
      }
    }
  }

  resolvePlacement(triggerRect, tipRect) {
    const requested = ["top", "bottom", "left", "right"].includes(this.placementValue)
      ? this.placementValue
      : "top"

    if (requested === "bottom" && triggerRect.bottom + OFFSET + tipRect.height > window.innerHeight - VIEWPORT_PADDING) {
      if (triggerRect.top - OFFSET - tipRect.height >= VIEWPORT_PADDING) return "top"
    }

    if (requested === "top" && triggerRect.top - OFFSET - tipRect.height < VIEWPORT_PADDING) {
      if (triggerRect.bottom + OFFSET + tipRect.height <= window.innerHeight - VIEWPORT_PADDING) return "bottom"
    }

    if (requested === "left" && triggerRect.left - OFFSET - tipRect.width < VIEWPORT_PADDING) {
      if (triggerRect.right + OFFSET + tipRect.width <= window.innerWidth - VIEWPORT_PADDING) return "right"
    }

    if (requested === "right" && triggerRect.right + OFFSET + tipRect.width > window.innerWidth - VIEWPORT_PADDING) {
      if (triggerRect.left - OFFSET - tipRect.width >= VIEWPORT_PADDING) return "left"
    }

    return requested
  }
}
