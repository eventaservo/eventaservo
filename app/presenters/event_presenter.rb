class EventPresenter
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers

  attr_reader :event

  def initialize(event:)
    @event = event
  end

  # Returns a Bootstrap badge indicating if the event is a master or child in a recurrence series.
  #
  # @return [String] safe HTML string
  def recurrence_type_badge_html
    if event.recurrent_master_event_id.nil?
      content_tag(:span, "Master", class: "badge bg-primary")
    else
      content_tag(:span, "Child", class: "badge bg-light text-dark")
    end
  end

  # Returns a Bootstrap badge for the event's recurrence status.
  #
  # @return [String] safe HTML string
  def recurrence_status_badge_html
    if event.detached_from_recurrent_series?
      content_tag(:span, "Detached", class: "badge bg-warning text-dark")
    elsif event.cancelled?
      content_tag(:span, "Cancelled", class: "badge bg-danger")
    elsif event.deleted?
      content_tag(:span, "Deleted", class: "badge bg-dark")
    elsif event.date_start < Time.current
      content_tag(:span, "Past", class: "badge bg-secondary")
    else
      content_tag(:span, "Upcoming", class: "badge bg-success")
    end
  end

  def add_to_calendar_links
    {
      ics: Calendar::AddToCalendarPresenter.new(event:, provider: :ics_file).url,
      google: Calendar::AddToCalendarPresenter.new(event:, provider: :google).url,
      apple: Calendar::AddToCalendarPresenter.new(event:, provider: :apple).url,
      outlook: Calendar::AddToCalendarPresenter.new(event:, provider: :outlook).url,
      yahoo: Calendar::AddToCalendarPresenter.new(event:, provider: :yahoo).url
    }
  end
end
