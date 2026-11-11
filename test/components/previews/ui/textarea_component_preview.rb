# frozen_string_literal: true

# Previews the Tailwind-based Ui::TextareaComponent across sizes, rows, and validation states.
class Ui::TextareaComponentPreview < ViewComponent::Preview
  # Interactive playground for testing multi-line text fields.
  #
  # @param label text "Field label"
  # @param placeholder text "Placeholder text"
  # @param rows number "Visible rows"
  # @param size select ["small", "medium"]
  # @param hint text "Helper text"
  # @param error text "Validation error message"
  # @param disabled toggle "Disable field"
  # @param readonly toggle "Read-only field"
  # @param required toggle "Required field"
  #
  # @return [String] rendered component
  def default(
    label: "Priskribo de la evento",
    placeholder: "Skribu detalan priskribon pri la celo, programo kaj celgrupo...",
    rows: 4,
    size: "medium",
    hint: "Vi povas uzi simplan tekston por priskribi vian eventon.",
    error: "",
    disabled: false,
    readonly: false,
    required: false
  )
    render Ui::TextareaComponent.new(
      :description,
      label: label,
      placeholder: placeholder,
      rows: rows,
      size: size.to_sym,
      hint: hint.presence,
      error: error.presence,
      disabled: disabled,
      readonly: readonly,
      required: required
    )
  end

  # Demonstrates both medium and large sizes.
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates normal, error, and disabled states.
  #
  # @return [String]
  def states
    render_with_template
  end
end
