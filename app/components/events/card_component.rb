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

  # Formats the event dates with abbreviated month names.
  #
  # @return [String] localized event date or date range
  def date_label
    start_date = event.komenca_dato
    end_date = event.fina_dato

    if event.samtaga?
      helpers.l(start_date, format: "%A, %e %b %Y").strip
    elsif start_date.year == end_date.year && start_date.month == end_date.month
      "#{start_date.day} - #{end_date.day} #{helpers.l(end_date, format: "%b %Y")}"
    elsif start_date.year == end_date.year
      "#{helpers.l(start_date, format: "%e %b").strip} - #{helpers.l(end_date, format: "%e %b %Y").strip}"
    else
      "#{helpers.l(start_date, format: "%e %b %Y").strip} - #{helpers.l(end_date, format: "%e %b %Y").strip}"
    end
  end
end
