# frozen_string_literal: true

# Presents event information for display and calendar links.
class EventPresenter
  include Rails.application.routes.url_helpers

  attr_reader :event

  # Creates a presenter for an event.
  #
  # @param event [Event] the event to present
  #
  # @return [EventPresenter] the new presenter
  def initialize(event:)
    @event = event
  end

  # Builds links for adding the event to supported calendars.
  #
  # @return [Hash{Symbol => String}] calendar links keyed by provider
  def add_to_calendar_links
    {
      ics: Calendar::AddToCalendarPresenter.new(event:, provider: :ics_file).url,
      google: Calendar::AddToCalendarPresenter.new(event:, provider: :google).url,
      apple: Calendar::AddToCalendarPresenter.new(event:, provider: :apple).url,
      outlook: Calendar::AddToCalendarPresenter.new(event:, provider: :outlook).url,
      yahoo: Calendar::AddToCalendarPresenter.new(event:, provider: :yahoo).url
    }
  end

  # Formats the event date or date range for display.
  #
  # @param abbreviated [Boolean] whether to abbreviate month names
  #
  # @return [String] the localized date label
  def date_label(abbreviated: false)
    start_date = event.komenca_dato
    end_date = event.fina_dato
    month = abbreviated ? "%b" : "%B"

    if event.samtaga?
      I18n.l(start_date, format: "%A, %e #{month} %Y").strip
    elsif end_date.year == start_date.year && end_date.month == start_date.month
      "#{start_date.day} - #{end_date.day} #{I18n.l(end_date, format: "#{month} %Y")}"
    elsif end_date.year == start_date.year
      "#{I18n.l(start_date, format: "%e #{month}")} - #{I18n.l(end_date, format: "%e #{month} %Y")}"
    else
      "#{I18n.l(start_date, format: "%e #{month} %Y").strip} - #{I18n.l(end_date, format: "%e #{month} %Y").strip}"
    end
  end
end
