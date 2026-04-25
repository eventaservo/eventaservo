# frozen_string_literal: true

module TimeZone
  # Normalizes legacy IANA timezone identifiers to canonical forms
  # recognized by ActiveSupport::TimeZone.
  #
  # Legacy identifiers like "Asia/Saigon" work on macOS but fail on
  # Linux systems where tzdata treats them as deprecated links.
  #
  # @example
  #   result = TimeZone::Normalize.call("Asia/Saigon")
  #   result.payload # => "Asia/Ho_Chi_Minh"
  #
  #   result = TimeZone::Normalize.call("America/New_York")
  #   result.payload # => "America/New_York"
  #
  class Normalize < ApplicationService
    # Legacy IANA identifiers that some tzdata versions no longer recognize.
    # Maps deprecated names to their current canonical equivalents.
    LEGACY_ZONES = {
      "Asia/Saigon" => "Asia/Ho_Chi_Minh",
      "Asia/Katmandu" => "Asia/Kathmandu",
      "Europe/Kiev" => "Europe/Kyiv",
      "America/Buenos_Aires" => "America/Argentina/Buenos_Aires",
      "US/Eastern" => "America/New_York",
      "US/Central" => "America/Chicago",
      "US/Mountain" => "America/Denver",
      "US/Pacific" => "America/Los_Angeles",
      "US/Alaska" => "America/Anchorage",
      "US/Hawaii" => "Pacific/Honolulu",
      "US/Arizona" => "America/Phoenix"
    }.freeze

    attr_reader :tz

    # @param tz [String] the timezone identifier to normalize
    def initialize(tz)
      @tz = tz
    end

    # @return [ApplicationService::Response] payload contains the canonical timezone string
    def call
      return success("Etc/UTC") if tz.blank?
      return success(LEGACY_ZONES[tz]) if LEGACY_ZONES.key?(tz)
      return success(tz) if Time.find_zone(tz)

      canonical = TZInfo::Timezone.get(tz).canonical_identifier
      return success(canonical) if Time.find_zone(canonical)

      failure("Unrecognized timezone: #{tz}")
    rescue TZInfo::InvalidTimezoneIdentifier
      failure("Invalid timezone identifier: #{tz}")
    end
  end
end
