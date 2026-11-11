# frozen_string_literal: true

# Previews the Tailwind-based Ui::CardComponent across variants, sizes, slots, and orientations.
class Ui::CardComponentPreview < ViewComponent::Preview
  # Interactive playground for testing card panel configurations.
  #
  # @param title text "Heading text"
  # @param subtitle text "Sub-heading text"
  # @param variant select ["default", "bordered", "elevated", "interactive", "accent_primary", "accent_success"]
  # @param size select ["small", "medium"]
  # @param flush toggle "Remove body padding"
  #
  # @return [String] rendered component
  def default(
    title: "Esperanto-Kongreso 2026",
    subtitle: "Universala Esperanto-Asocio",
    variant: "default",
    size: "medium",
    flush: false
  )
    render Ui::CardComponent.new(
      title:,
      subtitle:,
      variant: variant.to_sym,
      size: size.to_sym,
      flush:
    ) do
      "La Universala Kongreso de Esperanto estas la plej granda internacia renkontiĝo de esperantistoj el la tuta mondo."
    end
  end

  # Displays all visual panel variants side by side.
  #
  # @return [String]
  def all_variants
    render_with_template
  end

  # Displays small and medium sizes side by side.
  #
  # @return [String]
  def sizes
    render_with_template
  end

  # Demonstrates panels with media / cover images and aspect ratios.
  #
  # @return [String]
  def with_media
    render_with_template
  end

  # Demonstrates horizontal layout with media on the side and content on the right.
  #
  # @return [String]
  def horizontal
    render_with_template
  end

  # Demonstrates structured slots (:header, :body, :footer) with badges and action buttons.
  #
  # @return [String]
  def structured_slots
    render_with_template
  end

  # Demonstrates clickable panel with href, hover state, and focus visible ring.
  #
  # @return [String]
  def interactive_link
    render_with_template
  end

  # Demonstrates modern redesigns of admin mockup cards (Teachers, Speakers).
  #
  # @return [String]
  def mockup_examples
    render_with_template
  end
end
