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
    this._clearLoading = this.clearLoading.bind(this)
    this.frame.addEventListener("turbo:before-fetch-request", this._onBeforeFetch)
    this.frame.addEventListener("turbo:frame-render",         this._onFrameRender)
    this.frame.addEventListener("turbo:frame-missing",        this._clearLoading)
    document.addEventListener("turbo:before-cache",           this._clearLoading)
  }

  disconnect() {
    if (!this.frame) return

    this.clearLoading()
    this.frame.removeEventListener("turbo:before-fetch-request", this._onBeforeFetch)
    this.frame.removeEventListener("turbo:frame-render",         this._onFrameRender)
    this.frame.removeEventListener("turbo:frame-missing",        this._clearLoading)
    this.frame.removeEventListener("turbo:fetch-request-error",  this._clearLoading)
    document.removeEventListener("turbo:before-cache",           this._clearLoading)
  }

  onBeforeFetch(event) {
    // Only apply loading state for actual frame navigations targeting this frame,
    // ignoring bubbling events from child links (e.g. Turbo 8 hover prefetches or _top visits)
    // because those never fire turbo:frame-render and would leave the frame locked.
    if (event.target !== this.frame) return

    const headers = event.detail?.fetchOptions?.headers
    const purpose = headers?.["X-Sec-Purpose"] || headers?.["Sec-Purpose"] || headers?.["Purpose"]
    if (purpose === "prefetch") return

    this.frame.removeEventListener("turbo:fetch-request-error", this._clearLoading)
    this.frame.classList.add("calendar--loading")
    this.frame.addEventListener("turbo:fetch-request-error", this._clearLoading, { once: true })
  }

  clearLoading() {
    this.frame?.classList.remove("calendar--loading")
  }

  // Updates the browser URL after Turbo Frame navigation and scrolls the
  // calendar into view so footer navigation lands back at the top of the calendar.
  onFrameRender() {
    this.clearLoading()

    const newDate = this.frame.dataset.date
    if (!newDate) return

    const url = new URL(window.location)
    url.searchParams.set("date", newDate)
    history.replaceState({}, "", url)

    this.element.scrollIntoView({ behavior: "smooth", block: "start" })
  }
}
