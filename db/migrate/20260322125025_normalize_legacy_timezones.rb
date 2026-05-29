# frozen_string_literal: true

# Normalizes legacy IANA timezone identifiers in the events table.
#
# Some events have deprecated timezone names (e.g., "Asia/Saigon") that
# work on macOS but fail on Linux systems where tzdata treats them as
# deprecated links. This migration updates them to their canonical forms.
class NormalizeLegacyTimezones < ActiveRecord::Migration[8.0]
  # @return [void]
  def up
    Event.unscoped.find_each do |event|
      result = TimeZone::Normalize.call(event.time_zone)
      normalized = result.success? ? result.payload : "Etc/UTC"
      event.update_column(:time_zone, normalized) if normalized != event.time_zone
    end
  end

  # @return [void]
  def down
    # Intentionally left blank — cannot reverse timezone normalization
  end
end
