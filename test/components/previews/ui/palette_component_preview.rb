# frozen_string_literal: true

# Previews the Eventa Servo design system color palette and theme tokens.
class Ui::PaletteComponentPreview < ViewComponent::Preview
  # Displays the complete design system color palette organized by domain roles.
  #
  # @return [String]
  def all
    render_with_template
  end

  # Displays the Esperanto heritage greens (primary brand identity).
  #
  # @return [String]
  def esperanto_greens
    render_with_template
  end

  # Displays the event timing lifecycle colors (today, 7 days, 30 days, future, past).
  #
  # @return [String]
  def event_timing
    render_with_template
  end

  # Displays brand action and feedback colors (blue, info teal, red, warning amber).
  #
  # @return [String]
  def brand_colors
    render_with_template
  end

  # Displays neutral gray surfaces, text colors, and borders.
  #
  # @return [String]
  def neutrals
    render_with_template
  end
end
