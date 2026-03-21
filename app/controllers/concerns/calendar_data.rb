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
  # Parses the date param, builds navigation paths, and delegates
  # event querying/grouping to {Events::ByDatesQuery}.
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
    @calendar_date = parse_calendar_date
    build_navigation_paths
    build_calendar_month_navigation_options

    @events_by_day = Events::ByDatesQuery.new(
      from: @calendar_date,
      to: @calendar_date + 6.days,
      scope: @events,
      timezone: cookies[:horzono].presence
    ).call
  end

  # Parses the date parameter from the request, defaulting to today.
  #
  # @return [Date]
  def parse_calendar_date
    Date.iso8601(params[:date])
  rescue ArgumentError, TypeError
    Date.current
  end

  # Permitted query params preserved on calendar navigation URLs.
  #
  # @return [ActionController::Parameters]
  def calendar_navigation_filter_params
    params.permit(:o, :s, :t, :continent, :country_name, :city_name, :username)
  end

  # Builds prev/next/today navigation paths, preserving filter params
  # but excluding +:periodo+.
  #
  # @return [void]
  def build_navigation_paths
    filter_params = calendar_navigation_filter_params
    @calendar_today_path = url_for(filter_params.merge(date: Date.current.iso8601))
    @calendar_prev_path = url_for(filter_params.merge(date: (@calendar_date - 7.days).iso8601))
    @calendar_next_path = url_for(filter_params.merge(date: (@calendar_date + 7.days).iso8601))
  end

  # Builds labeled URLs for navigating to the first day of each month in the
  # current month plus the next eleven months (twelve entries total).
  #
  # @return [void]
  def build_calendar_month_navigation_options
    filter_params = calendar_navigation_filter_params
    anchor = Time.zone.today.beginning_of_month
    @calendar_month_navigation_options = (0..11).map do |i|
      month_start = anchor.advance(months: i)
      label = I18n.l(month_start, format: :month_navigation).capitalize
      path = url_for(filter_params.merge(date: month_start.iso8601))
      [label, path]
    end
  end
end
