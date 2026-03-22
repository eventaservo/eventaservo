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
