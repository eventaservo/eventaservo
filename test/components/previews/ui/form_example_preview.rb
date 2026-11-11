# frozen_string_literal: true

# Previews complete, realistic form layouts integrating all Tailwind-based form components.
class Ui::FormExamplePreview < ViewComponent::Preview
  # Realistic event creation form showcasing all form components together.
  #
  # @return [String]
  def default
    render_with_template
  end
end
