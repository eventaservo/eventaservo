# frozen_string_literal: true

# Previews the Tailwind-based Ui::CheckboxComponent across checked states, sizes, and validation.
class Ui::CheckboxComponentPreview < ViewComponent::Preview
  # Interactive playground for testing checkboxes.
  #
  # @param label text "Checkbox label"
  # @param checked toggle "Checked state"
  # @param size select ["small", "medium"]
  # @param hint text "Helper text"
  # @param error text "Validation error message"
  # @param disabled toggle "Disable checkbox"
  # @param required toggle "Required checkbox"
  #
  # @return [String] rendered component
  def default(
    label: "Mi konsentas ricevi retpoŝtajn sciigojn pri novaj eventoj",
    checked: true,
    size: "medium",
    hint: "Vi povos malaboni iam ajn per ligilo en la retmesaĝo.",
    error: "",
    disabled: false,
    required: false
  )
    render Ui::CheckboxComponent.new(
      :notifications,
      label: label,
      checked: checked,
      size: size.to_sym,
      hint: hint.presence,
      error: error.presence,
      disabled: disabled,
      required: required
    )
  end

  # Demonstrates small and medium sizes.
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates normal, checked, disabled, and error states.
  #
  # @return [String]
  def states
    render_with_template
  end
end
