# frozen_string_literal: true

module TimeZone
  # Converts a wall-clock datetime (the year/month/day/hour/min components
  # of an input +Time+ or +ActiveSupport::TimeWithZone+) into a UTC +Time+
  # under a given IANA time zone.
  #
  # Applies deterministic policies for DST boundaries so that a save never
  # raises on user-typed wall-clock values that fall on a transition:
  #
  # * Ambiguous local time (fall-back overlap) — picks the DST occurrence
  #   (first occurrence, summer-time offset). Reasoning: the form shows the
  #   user a single wall-clock value, and choosing DST matches what the
  #   form would round-trip back to them.
  # * Non-existent local time (spring-forward gap) — shifts the input
  #   forward by one hour, landing the event right after the gap rather
  #   than failing the save.
  #
  # @example
  #   result = TimeZone::WallClockToUtc.call(time_zone: "Europe/Brussels", datetime: "2026-05-16 12:00".to_time)
  #   result.payload # => 2026-05-16 10:00:00 UTC
  #
  class WallClockToUtc < ApplicationService
    attr_reader :time_zone, :datetime

    # @param time_zone [String] IANA identifier (e.g. "Europe/Brussels")
    # @param datetime [Time, ActiveSupport::TimeWithZone] only the
    #   year/month/day/hour/min components are read; the input's own zone
    #   is ignored.
    def initialize(time_zone:, datetime:)
      @time_zone = time_zone
      @datetime = datetime
    end

    # @return [ApplicationService::Response] payload is a UTC +Time+
    def call
      tz = TZInfo::Timezone.get(time_zone)
      local = Time.new(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.min)

      utc = begin
        tz.local_to_utc(local)
      rescue TZInfo::AmbiguousTime
        tz.local_to_utc(local, true)
      rescue TZInfo::PeriodNotFound
        tz.local_to_utc(local + 3600)
      end

      success(utc)
    end
  end
end
