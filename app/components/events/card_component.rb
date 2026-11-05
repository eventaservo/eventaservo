# frozen_string_literal: true

# Renders the existing event card for listings and reports.
class Events::CardComponent < ViewComponent::Base
  attr_reader :event

  # Creates a card for an event.
  #
  # @param event [Event] the event to display
  #
  # @return [Events::CardComponent] the new component
  def initialize(event:)
    @event = event
  end
end
