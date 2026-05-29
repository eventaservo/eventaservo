# frozen_string_literal: true

require "test_helper"

class ActiveSupport::TimeZoneTest < ActiveSupport::TestCase
  test "cet? should return true for timezones that are CET" do
    assert ActiveSupport::TimeZone["Europe/Paris"].cet?
  end

  test "cet? should return false for timezones that are not CET" do
    refute ActiveSupport::TimeZone["America/New_York"].cet?
  end
end
