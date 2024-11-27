module Calendar
  # This is the constructor class to generate the links for a event, based on a provider.
  #
  # @example ICS File
  #   Calendar::AddToCalendarPresenter.new(event:, provider: :ics_file).url
  #     => https://example.com/events/123.ics
  #
  # @example Google
  #   Calendar::AddToCalendarPresenter.new(event:, provider: :google).url
  #     => https://www.google.com/calendar/render?action=TEMPLATE&text=Event+title&dates=20220101T000000Z/20220101T000000Z&details=Event+description&location=Event+location
  #
  # To add new providers, you need to create a new class in the Calendar::Providers namespace that
  # implements the +url+ method.
  class AddToCalendarPresenter
    include Rails.application.routes.url_helpers

    attr_reader :event, :provider

    # @param event [Event]
    # @param provider [Symbol]
    def initialize(event:, provider:)
      @event = event
      @provider = provider
    end

    # @return [String] The URL to add the event to the calendar
    def url
      klass = "Calendar::Providers::#{provider.to_s.classify}".constantize

      klass.new(event: event, provider: provider).url
    end

    # @return [String] This will be displayed on the description of the event
    def details
      event_url(code: event.code) +
        "\n\n" +
        event.description
    end

    # @return [String] The physical location of the event, or the URL if is online
    def location
      event.full_address.presence || event_url(code: event.code)
    end
  end
end
