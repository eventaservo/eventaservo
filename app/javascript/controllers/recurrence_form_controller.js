import { Controller } from "@hotwired/stimulus"

// Manages the recurrence form's dynamic visibility of fields
// based on the selected frequency and options.
export default class extends Controller {
  static targets = [
    "frequency",
    "intervalLabel",
    "weeklyOptions",
    "monthlyOptions",
    "monthlyDayOfMonth",
    "monthlyNthWeekday",
    "monthlyTypeRadio",
    "yearlyOptions",
    "endDateField",
    "endTypeRadio"
  ]

  connect() {
    this.frequencyChanged()
    this.endTypeChanged()
  }

  frequencyChanged() {
    const frequency = this.frequencyTarget.value

    // Hide all frequency-specific sections
    this.weeklyOptionsTarget.style.display = "none"
    this.monthlyOptionsTarget.style.display = "none"
    this.yearlyOptionsTarget.style.display = "none"

    // Update interval label using translated data attributes
    const label = this.intervalLabelTarget
    const key = `label${frequency.charAt(0).toUpperCase() + frequency.slice(1)}`
    label.textContent = label.dataset[key] || ""

    // Show relevant section
    switch (frequency) {
      case "weekly":
        this.weeklyOptionsTarget.style.display = "block"
        break
      case "monthly":
        this.monthlyOptionsTarget.style.display = "block"
        this.monthlyTypeChanged()
        break
      case "yearly":
        this.yearlyOptionsTarget.style.display = "block"
        break
    }
  }

  monthlyTypeChanged() {
    const selectedRadio = this.monthlyTypeRadioTargets.find(r => r.checked)
    if (!selectedRadio) return

    if (selectedRadio.value === "day_of_month") {
      this.monthlyDayOfMonthTarget.style.display = "block"
      this.monthlyNthWeekdayTarget.style.display = "none"
    } else {
      this.monthlyDayOfMonthTarget.style.display = "none"
      this.monthlyNthWeekdayTarget.style.display = "block"
    }
  }

  endTypeChanged() {
    const onDateRadio = this.endTypeRadioTargets.find(r => r.value === "on_date")
    if (onDateRadio && onDateRadio.checked) {
      this.endDateFieldTarget.style.display = "block"
    } else {
      this.endDateFieldTarget.style.display = "none"
    }
  }
}
