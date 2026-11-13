# frozen_string_literal: true

# Previews the Tailwind-based Ui::DropdownComponent across alignments, directions, and contexts.
class Ui::DropdownComponentPreview < ViewComponent::Preview
  # Default left-aligned menu with icons and actions.
  #
  # @return [String]
  def default
    render_with_template
  end

  # Right-aligned user profile menu with section header, dividers, and destructive action.
  #
  # @return [String]
  def right_aligned
    render_with_template
  end

  # Upward-opening menu suitable for footer links.
  #
  # @return [String]
  def dropup
    render_with_template
  end

  # Calendar export menu with brand icons and ICS download.
  #
  # @return [String]
  def add_to_calendar
    render_with_template
  end
end
