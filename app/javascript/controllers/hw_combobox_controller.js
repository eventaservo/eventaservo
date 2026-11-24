import HwComboboxController from "@josefarias/hotwire_combobox"

// Guards hotwire_combobox's prepareToFilter against synthetic keydown events
// that omit `event.key` (e.g. Chrome autofill).
export default class extends HwComboboxController {
  prepareToFilter(event) {
    if (typeof event?.key !== "string") return

    super.prepareToFilter(event)
  }
}
