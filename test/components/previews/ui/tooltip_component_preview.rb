# frozen_string_literal: true

# Previews the Tailwind-based Ui::TooltipComponent and Stimulus `hint` controller.
class Ui::TooltipComponentPreview < ViewComponent::Preview
  # Default icon trigger displaying an Esperanto hint on hover or keyboard focus.
  #
  # @return [String]
  def default
    render_with_template
  end

  # Four placement directions (top, bottom, left, right) side by side.
  #
  # @return [String]
  def placements
    render_with_template
  end

  # Icon-only triggers matching navbar tools and event timezone badges.
  #
  # @return [String]
  def icon_triggers
    render_with_template
  end
end
