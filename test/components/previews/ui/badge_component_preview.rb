# frozen_string_literal: true

# Previews the Tailwind-based Ui::BadgeComponent across variants, shapes, and contexts.
class Ui::BadgeComponentPreview < ViewComponent::Preview
  # Interactive playground for testing badge configurations.
  #
  # @param text text "Badge label"
  # @param variant select ["info", "warning", "success", "secondary", "light", "danger", "international", "nearby"]
  # @param shape select ["pill", "rounded"]
  # @param size select ["small", "medium", "large"]
  # @return [String] rendered component
  def default(text: "Kunveno", variant: "info", shape: "pill", size: "medium")
    render Ui::BadgeComponent.new(
      text,
      variant: variant.to_sym,
      shape: shape.to_sym,
      size: size.to_sym
    )
  end

  # Displays all semantic badge variants side by side.
  #
  # @return [String]
  def all_variants
    render_with_template
  end

  # Demonstrates pill vs rounded shapes.
  #
  # @return [String]
  def shapes
    render_with_template
  end

  # Demonstrates all badge sizes (small, medium, large).
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates realistic event tags as seen in event cards and detail pages.
  #
  # @return [String]
  def event_tags_example
    render_with_template
  end

  # Demonstrates filter tags with active (removable) and inactive states.
  #
  # @return [String]
  def filter_tags_example
    render_with_template
  end

  # Demonstrates badges rendered as clickable anchor tags.
  #
  # @return [String]
  def as_link
    render_with_template
  end
end
