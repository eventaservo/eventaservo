# frozen_string_literal: true

require "test_helper"

module ActiveSupport
  class TimeZoneTest < ActionView::TestCase
    test ".cet?" do
      assert_not ActiveSupport::TimeZone["Europe/London"].cet?
      assert ActiveSupport::TimeZone["Europe/Paris"].cet?
    end
  end
end
