# frozen_string_literal: true

# Shared logic for preparing native calendar view assigns.
# Include in any controller that may render the calendar partial via
# {EventsHelper#display_events_by_style}.
#
# @example Usage in a controller action
#   # Caller must set @events to an unfiltered (includes-today) scope first:
#   @events = Event.ne_nuligitaj.chefaj.by_continent("reta")
#   prepare_calendar_data
module CalendarData
  extend ActiveSupport::Concern

  private

  # Prepares assigns for the native calendar partial.
  #
  # Builds a 7-day window starting from the requested date (or today),
  # groups events falling within that window by day, and computes the
  # navigation paths for prev/next/today preserving active filter params.
  #
  # The +periodo+ param is intentionally excluded from navigation paths:
  # period-based scopes (today-only, 7-day, etc.) conflict with the calendar's
  # own date-window query and would produce silently empty weeks.
  #
  # @note Callers must assign +@events+ to a relation that includes today's
  #   events before calling this method. Using a +not_today+-scoped relation
  #   will cause today's events to be absent from the calendar.
  # @return [void]
  def prepare_calendar_data
    @calendar_date = begin
      Date.iso8601(params[:date])
    rescue ArgumentError, TypeError
      Date.current
    end

    # Exclude :periodo — period filters conflict with the calendar's own date-window query.
    filter_params = params.permit(:o, :s, :t, :continent, :country_name, :city_name, :username)
    @calendar_today_path = url_for(filter_params.merge(date: Date.current.iso8601))
    @calendar_prev_path = url_for(filter_params.merge(date: (@calendar_date - 7.days).iso8601))
    @calendar_next_path = url_for(filter_params.merge(date: (@calendar_date + 7.days).iso8601))

    calendar_events = @events.by_dates(
      from: @calendar_date.beginning_of_day,
      to: (@calendar_date + 6.days).end_of_day
    )
    user_timezone = cookies[:horzono].presence
    @events_by_day = calendar_events.order(:date_start).group_by { |e|
      begin
        tz = user_timezone || e.time_zone
        e.date_start.in_time_zone(tz).to_date
      rescue ArgumentError, TZInfo::InvalidTimezoneIdentifier
        e.date_start.in_time_zone(e.time_zone).to_date
      end
    }
  end
end
