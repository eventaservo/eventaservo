# frozen_string_literal: true

module Events
  # Groups events into a date window, correctly placing multi-day events
  # on every day they span within the window.
  #
  # Unlike a simple +group_by+ on +date_start+, this ensures events that
  # start before the window but extend into it appear on each visible day.
  #
  # @example 7-day calendar window
  #   result = Events::ByDatesQuery.new(
  #     from: Date.current,
  #     to: Date.current + 6.days
  #   ).call
  #   result[Date.current] # => [Event, ...]
  #
  # @example Single day with custom scope
  #   result = Events::ByDatesQuery.new(
  #     from: Date.current,
  #     to: Date.current,
  #     scope: Event.venontaj.chefaj.by_continent("eŭropo")
  #   ).call
  #
  class ByDatesQuery
    attr_reader :from, :to, :scope, :timezone

    # @param from [Date] first day of the window
    # @param to [Date] last day of the window
    # @param scope [ActiveRecord::Relation] pre-filtered event relation
    # @param timezone [String, nil] IANA timezone for date resolution
    #   (e.g. "America/Sao_Paulo"). When nil, each event's own +time_zone+
    #   attribute is used.
    def initialize(from:, to:, scope: Event.venontaj.chefaj, timezone: nil)
      @from = from
      @to = to
      @scope = scope
      @timezone = timezone
    end

    # Fetches events within the window and groups them by each day they cover.
    #
    # @return [Hash{Date => Array<Event>}] events keyed by day, sorted
    #   (all-day first, then by +date_start+). Every day in the window has
    #   a key, even if the array is empty.
    def call
      events = fetch_events
      group_by_day(events)
    end

    private

    # @return [Array<Event>]
    def fetch_events
      scope
        .by_dates(from: from.beginning_of_day, to: to.end_of_day)
        .order(:date_start)
        .to_a
    end

    # Pre-resolves each event's start/end dates once, then distributes
    # them across the days they cover. This avoids redundant timezone
    # conversions when the same event spans multiple days.
    #
    # @param events [Array<Event>]
    # @return [Hash{Date => Array<Event>}]
    def group_by_day(events)
      dated_events = events.map { |e| [e, resolve_date(e, :date_start), resolve_date(e, :date_end)] }

      (from..to).each_with_object({}) do |day, hash|
        day_events = dated_events
          .select { |_, start_date, end_date| day.between?(start_date, end_date) }
          .map(&:first)
        hash[day] = sort_events(day_events)
      end
    end

    # Converts an event timestamp to a Date in the appropriate timezone.
    #
    # @param event [Event]
    # @param attribute [Symbol] :date_start or :date_end
    # @return [Date]
    def resolve_date(event, attribute)
      timestamp = event.public_send(attribute) || event.date_start
      tz = timezone || event.time_zone
      timestamp.in_time_zone(tz).to_date
    rescue ArgumentError, TZInfo::InvalidTimezoneIdentifier
      timestamp.in_time_zone(event.time_zone).to_date
    end

    # All-day events appear first within each day, then by start time.
    #
    # @param events [Array<Event>]
    # @return [Array<Event>]
    def sort_events(events)
      events.sort_by { |e| [e.tuttaga? ? 0 : 1, e.date_start] }
    end
  end
end
