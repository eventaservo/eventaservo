# frozen_string_literal: true

# Previews the Tailwind-based Ui::ButtonComponent across variants, sizes, and contexts.
class Ui::ButtonComponentPreview < ViewComponent::Preview
  # Interactive playground for testing button configurations.
  #
  # @param text text "Button label"
  # @param variant select ["primary", "success", "secondary", "outline_primary", "outline_danger", "danger", "cancel", "delete", "new_link", "link"]
  # @param size select ["small", "medium", "large"]
  # @param disabled toggle "Disabled state"
  # @param full_width toggle "Full width"
  # @return [String] rendered component
  def default(text: "Konservi", variant: "primary", size: "medium", disabled: false, full_width: false)
    render Ui::ButtonComponent.new(
      text,
      variant: variant.to_sym,
      size: size.to_sym,
      disabled:,
      full_width:
    )
  end

  # Displays all visual button variants side by side.
  #
  # @return [String]
  def all_variants
    render_with_template
  end

  # Displays all available sizes (small, medium, large).
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates buttons with leading and trailing Font Awesome icons.
  #
  # @return [String]
  def with_icons
    render_with_template
  end

  # Demonstrates rendering as an anchor tag when href is provided.
  #
  # @return [String]
  def as_link
    render_with_template
  end

  # Demonstrates disabled states for both button and link variants.
  #
  # @return [String]
  def disabled_states
    render_with_template
  end

  # Demonstrates the standard form footer layout [Delete ... Cancel ... Save].
  #
  # @return [String]
  def in_footer_context
    render_with_template
  end
end
