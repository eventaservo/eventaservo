# frozen_string_literal: true

# Previews the Tailwind-based Ui::ModalComponent across sizes and form layouts.
class Ui::ModalComponentPreview < ViewComponent::Preview
  # Standard medium dialog with body copy and close footer action.
  #
  # @param open toggle "Open dialog automatically when the preview loads"
  # @return [String]
  def default(open: true)
    render_with_template(locals: {open: ActiveModel::Type::Boolean.new.cast(open)})
  end

  # Wide large dialog with scrollable body content.
  #
  # @param open toggle "Open dialog automatically when the preview loads"
  # @return [String]
  def large(open: true)
    render_with_template(locals: {open: ActiveModel::Type::Boolean.new.cast(open)})
  end

  # Dialog containing a structured form and submit action.
  #
  # @param open toggle "Open dialog automatically when the preview loads"
  # @return [String]
  def form(open: true)
    render_with_template(locals: {open: ActiveModel::Type::Boolean.new.cast(open)})
  end
end
