module Calendar
  module Providers
    class Google < AddToCalendarPresenter
      # @return [String] The URL to add the event to the calendar
      def url
        base_url = "https://www.google.com/calendar/render"

        params = {
          action: "TEMPLATE",
          text: event.title,
          dates: "#{event.date_start.utc.strftime("%Y%m%dT%H%M%SZ")}/#{event.date_end.utc.strftime("%Y%m%dT%H%M%SZ")}",
          details: details,
          location: location
        }

        uri = URI(base_url)
        uri.query = URI.encode_www_form(params)
        uri.to_s
      end
    end
  end
end
