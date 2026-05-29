import { Controller } from "@hotwired/stimulus"

// Wraps a native <input type="date"> with DD/MM/YYYY conversion.
// The browser displays its native date picker (YYYY-MM-DD internally),
// while the form submits DD/MM/YYYY as expected by the backend.
//
// Usage: <div data-controller="datepicker">
//          <input type="hidden" name="event[date_start]" data-datepicker-target="hidden">
//          <input type="date" data-datepicker-target="input" data-initial="31/12/2026">
//        </div>
export default class extends Controller {
  static targets = ["input", "hidden"]

  connect() {
    const initial = this.inputTarget.dataset.initial
    if (initial) {
      this.inputTarget.value = this.toISO(initial)
    }
    this.sync()

    this._lastKeyAt = 0
    this._onKey = () => { this._lastKeyAt = Date.now() }
    this.inputTarget.addEventListener("keydown", this._onKey)
  }

  disconnect() {
    this.#cancelScheduled()
    this.inputTarget.removeEventListener("keydown", this._onKey)
  }

  sync() {
    this.hiddenTarget.value = this.toDMY(this.inputTarget.value)
    this.#scheduleComplete()
  }

  // Triggered on blur — user finished editing via keyboard (Tab / click away)
  complete() {
    this.#cancelScheduled()
    if (!this.inputTarget.value) return
    this.dispatch("complete", { detail: { iso: this.inputTarget.value, dmy: this.hiddenTarget.value } })
  }

  // After a calendar popup selection the input keeps focus (no blur).
  // Auto-advance only when there was no recent keyboard activity.
  #scheduleComplete() {
    this.#cancelScheduled()
    if (!this.inputTarget.value) return
    this._completeTimer = setTimeout(() => {
      const recentKeyboard = (Date.now() - this._lastKeyAt) < 400
      if (document.activeElement === this.inputTarget && !recentKeyboard) {
        this.dispatch("complete", { detail: { iso: this.inputTarget.value, dmy: this.hiddenTarget.value } })
      }
    }, 200)
  }

  #cancelScheduled() {
    if (this._completeTimer) {
      clearTimeout(this._completeTimer)
      this._completeTimer = null
    }
  }

  // "31/12/2026" → "2026-12-31"
  toISO(dmy) {
    const [d, m, y] = dmy.split("/")
    return `${y}-${m}-${d}`
  }

  // "2026-12-31" → "31/12/2026"
  toDMY(iso) {
    if (!iso) return ""
    const [y, m, d] = iso.split("-")
    return `${d}/${m}/${y}`
  }
}
