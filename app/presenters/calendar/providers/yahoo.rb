module Calendar
  module Providers
    class Yahoo < AddToCalendarPresenter
      # @return [String] The URL to add the event to the calendar
      def url
        base_url = "https://calendar.yahoo.com/"
        params = {
          v: 60,
          view: "d",
          type: 20,
          title: event.title,
          st: event.date_start.utc.strftime("%Y%m%dT%H%M%SZ"),
          et: event.date_end.utc.strftime("%Y%m%dT%H%M%SZ"),
          desc: details,
          in_loc: location
        }

        uri = URI(base_url)
        uri.query = URI.encode_www_form(params)
        uri.to_s
      end
    end
  end
end
