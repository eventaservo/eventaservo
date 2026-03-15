import { Controller } from "@hotwired/stimulus"

// Manages the native server-rendered week-list calendar.
// Turbo Frames handle all navigation; this controller keeps the browser URL
// in sync after frame navigation so pages are bookmarkable and shareable.
export default class extends Controller {
  connect() {
    this.frame = this.element.querySelector("turbo-frame")
    this.frame.addEventListener("turbo:frame-render", this.onFrameRender.bind(this))
  }

  disconnect() {
    this.frame.removeEventListener("turbo:frame-render", this.onFrameRender.bind(this))
  }

  // Updates the browser URL after Turbo Frame navigation using the date
  // attribute on the frame element, which is re-rendered on every navigation.
  onFrameRender() {
    const newDate = this.frame.dataset.date
    if (!newDate) return

    const url = new URL(window.location)
    url.searchParams.set("date", newDate)
    history.replaceState({}, "", url)
  }
}
