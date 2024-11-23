module Calendar
  module Providers
    class Apple < AddToCalendarPresenter
      # @return [String] The URL to add the event to the calendar
      def url
        event_url(code: event.code, format: :ics)
      end
    end
  end
end
