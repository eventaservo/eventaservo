import { Controller } from "@hotwired/stimulus"

// Manages the native server-rendered week-list calendar.
// Turbo Frames handle all navigation; this controller keeps the browser URL
// in sync after frame navigation so pages are bookmarkable and shareable.
export default class extends Controller {
  connect() {
    this.frame = this.element.querySelector("turbo-frame")
    if (!this.frame) return

    this._onBeforeFetch = this.onBeforeFetch.bind(this)
    this._onFrameRender = this.onFrameRender.bind(this)
    this.frame.addEventListener("turbo:before-fetch-request", this._onBeforeFetch)
    this.frame.addEventListener("turbo:frame-render",         this._onFrameRender)
  }

  disconnect() {
    if (!this.frame) return

    this.frame.removeEventListener("turbo:before-fetch-request", this._onBeforeFetch)
    this.frame.removeEventListener("turbo:frame-render",         this._onFrameRender)
  }

  onBeforeFetch() {
    this.frame.classList.add("calendar--loading")
    this.frame.addEventListener("turbo:fetch-request-error", this._onFrameRender, { once: true })
  }

  // Updates the browser URL after Turbo Frame navigation using the date
  // attribute on the frame element, which is re-rendered on every navigation.
  onFrameRender() {
    this.frame.classList.remove("calendar--loading")

    const newDate = this.frame.dataset.date
    if (!newDate) return

    const url = new URL(window.location)
    url.searchParams.set("date", newDate)
    history.replaceState({}, "", url)
  }
}
