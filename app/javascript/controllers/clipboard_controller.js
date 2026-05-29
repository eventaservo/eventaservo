import { Controller } from "@hotwired/stimulus"

// Copies text to the clipboard using the native Clipboard API.
//
// Two modes:
//   1. With a "source" target — copies the value of that input/textarea.
//   2. With a "text" value  — copies the literal string.
//
// Usage (source target):
//   <div data-controller="clipboard">
//     <input data-clipboard-target="source" value="...">
//     <button data-action="clipboard#copy">Copy</button>
//   </div>
//
// Usage (text value):
//   <span data-controller="clipboard" data-clipboard-text-value="hello@example.com"
//         data-action="click->clipboard#copy">...</span>
export default class extends Controller {
  static targets = ["source"]
  static values = { text: String }

  copy(event) {
    event.preventDefault()

    const text = this.hasSourceTarget ? this.sourceTarget.value : this.textValue

    navigator.clipboard.writeText(text).then(() => {
      this.#showFeedback(text)
    }).catch(() => {
      alert("Ne eblis kopii al la tondujo")
    })
  }

  // @private
  #showFeedback(text) {
    if (this.hasSourceTarget) {
      this.sourceTarget.select()
    }
    alert(`${text} sukcese kopiita al la tondujo!`)
  }
}
