# frozen_string_literal: true

# Previews the event card using an event from the development database.
class Events::CardComponentPreview < ViewComponent::Preview
  # Displays an existing event.
  #
  # @return [String] rendered event card
  def default
    render Events::CardComponent.new(event: Event.order(:id).first!)
  end
end
