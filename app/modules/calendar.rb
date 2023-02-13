# frozen_string_literal: true

module Calendar
  def self.utc_offset(time_zone)
    ActiveSupport::TimeZone[time_zone].utc_offset
  end
end
