# frozen_string_literal: true

# Previews the Tailwind-based Ui::TabsComponent with icons and count pills.
class Ui::TabsComponentPreview < ViewComponent::Preview
  # Default tabs layout with icons and three panels.
  #
  # @return [String]
  def default
    render_with_template
  end

  # Organization-style tabs showing item count pills on each tab.
  #
  # @return [String]
  def with_counts
    render_with_template
  end
end
