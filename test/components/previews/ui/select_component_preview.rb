# frozen_string_literal: true

# Previews the Tailwind-based Ui::SelectComponent across sizes, options, and validation states.
class Ui::SelectComponentPreview < ViewComponent::Preview
  # Interactive playground for testing select menus.
  #
  # @param label text "Field label"
  # @param size select ["small", "medium"]
  # @param hint text "Helper text"
  # @param error text "Validation error message"
  # @param disabled toggle "Disable field"
  # @param required toggle "Required field"
  #
  # @return [String] rendered component
  def default(
    label: "Lando",
    size: "medium",
    hint: "Elektu la landon kie la evento okazos.",
    error: "",
    disabled: false,
    required: true
  )
    render Ui::SelectComponent.new(
      :country_id,
      label: label,
      size: size.to_sym,
      include_blank: "Elektu landon...",
      options: [
        ["Brazilo", 1],
        ["Francio", 2],
        ["Germanio", 3],
        ["Japanio", 4],
        ["Pollando", 5]
      ],
      selected: 1,
      hint: hint.presence,
      error: error.presence,
      disabled: disabled,
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
