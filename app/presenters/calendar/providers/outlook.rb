module Calendar
  module Providers
    class Outlook < AddToCalendarPresenter
      # @return [String] The URL to add the event to the calendar
      def url
        base_url = "https://outlook.live.com/calendar/0/deeplink/compose"
        params = {
          path: "/calendar/action/compose",
          rru: "addevent",
          subject: event.title,
          startdt: event.date_start.utc.iso8601,
          enddt: event.date_end.utc.iso8601,
          body: details,
          location: location
        }

        uri = URI(base_url)
        uri.query = URI.encode_www_form(params)
        uri.to_s
      end
    end
  end
end
