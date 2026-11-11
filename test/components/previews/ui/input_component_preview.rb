# frozen_string_literal: true

# Previews the Tailwind-based Ui::InputComponent across types, sizes, icons, and validation states.
class Ui::InputComponentPreview < ViewComponent::Preview
  # Interactive playground for testing input field configurations.
  #
  # @param label text "Field label"
  # @param placeholder text "Placeholder text"
  # @param value text "Field value"
  # @param type select ["text", "email", "password", "number", "date", "search", "url"]
  # @param size select ["small", "medium"]
  # @param hint text "Helper text"
  # @param error text "Validation error message"
  # @param icon text "Icon name (e.g. search, user, envelope)"
  # @param disabled toggle "Disable field"
  # @param readonly toggle "Read-only field"
  # @param required toggle "Required field"
  #
  # @return [String] rendered component
  def default(
    label: "Retpoŝtadreso",
    placeholder: "ekzemplo@esperanto.org",
    value: "",
    type: "email",
    size: "medium",
    hint: "Ni neniam dividos vian retpoŝton kun triaj partioj.",
    error: "",
    icon: "envelope",
    disabled: false,
    readonly: false,
    required: true
  )
    render Ui::InputComponent.new(
      :email,
      label: label,
      placeholder: placeholder,
      value: value.presence,
      type: type.to_sym,
      size: size.to_sym,
      hint: hint.presence,
      error: error.presence,
      icon: icon.presence,
      disabled: disabled,
      readonly: readonly,
      required: required
    )
  end

  # Demonstrates both medium (default) and large sizes.
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates fields with leading and trailing icons.
  #
  # @return [String]
  def with_icons
    render_with_template
  end

  # Demonstrates normal, focus, disabled, readonly, and validation error states.
  #
  # @return [String]
  def states
    render_with_template
  end

  # Demonstrates various HTML5 input types (text, email, password, date, search, number).
  #
  # @return [String]
  def input_types
    render_with_template
  end
end
