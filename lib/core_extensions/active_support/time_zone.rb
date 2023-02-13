# frozen_string_literal: true

module ActiveSupport
  class TimeZone
    # Returns true if the time zone is CET (Central European Time)
    #
    # @return [Boolean]
    def cet?
      utc_offset == 3600
    end
    alias met? cet?
  end
end
