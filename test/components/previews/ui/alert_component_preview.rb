# frozen_string_literal: true

# Previews the Tailwind-based Ui::AlertComponent across variants, sizes, and contexts.
class Ui::AlertComponentPreview < ViewComponent::Preview
  # Interactive playground for testing notification banner configurations.
  #
  # @param text text "Banner content text"
  # @param variant select ["info", "primary", "notice", "success", "warning", "danger", "error", "secondary", "light"]
  # @param size select ["medium", "large"]
  # @param title text "Optional heading"
  # @param icon toggle "Show contextual icon"
  # @param dismissible toggle "Show dismiss close button"
  #
  # @return [String] rendered component
  def default(
    text: "Tiu ĉi estas grava informo por uzantoj de Eventa Servo.",
    variant: "info",
    size: "medium",
    title: "",
    icon: true,
    dismissible: true
  )
    render Ui::AlertComponent.new(
      text,
      variant: variant.to_sym,
      size: size.to_sym,
      title: title.presence,
      icon: icon,
      dismissible: dismissible
    )
  end

  # Displays all contextual color variants side by side.
  #
  # @return [String]
  def all_variants
    render_with_template
  end

  # Demonstrates banners with contextual icons.
  #
  # @return [String]
  def with_icons
    render_with_template
  end

  # Demonstrates banners with headings and rich text content including links.
  #
  # @return [String]
  def with_headings
    render_with_template
  end

  # Demonstrates the two size options: medium (default) and large.
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates dismissible banners with interactive close buttons.
  #
  # @return [String]
  def dismissible
    render_with_template
  end

  # Demonstrates the top-floating flash banner mode used in layouts.
  #
  # @return [String]
  def flash_messages
    render_with_template
  end
end
