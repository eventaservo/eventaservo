class EventPresenter
  include Rails.application.routes.url_helpers

  attr_reader :event

  def initialize(event:)
    @event = event
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
