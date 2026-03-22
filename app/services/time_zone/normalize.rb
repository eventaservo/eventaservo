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
    attr_reader :tz

    # @param tz [String] the timezone identifier to normalize
    def initialize(tz)
      @tz = tz
    end

    # @return [ApplicationService::Response] payload contains the canonical timezone string
    def call
      return success("Etc/UTC") if tz.blank?
      return success(tz) if Time.find_zone(tz)

      canonical = TZInfo::Timezone.get(tz).canonical_identifier
      return success(canonical) if Time.find_zone(canonical)

      failure("Unrecognized timezone: #{tz}")
    rescue TZInfo::InvalidTimezoneIdentifier
      failure("Invalid timezone identifier: #{tz}")
    end
  end
end
