# frozen_string_literal: true

require "test_helper"

class TimeZone::NormalizeTest < ActiveSupport::TestCase
  test "returns success with the same zone when ActiveSupport recognizes it" do
    result = TimeZone::Normalize.call("America/New_York")

    assert result.success?
    assert_equal "America/New_York", result.payload
  end

  test "returns success with Etc/UTC for blank input" do
    result = TimeZone::Normalize.call("")

    assert result.success?
    assert_equal "Etc/UTC", result.payload
  end

  test "returns success with Etc/UTC for nil input" do
    result = TimeZone::Normalize.call(nil)

    assert result.success?
    assert_equal "Etc/UTC", result.payload
  end

  test "returns success for a legacy identifier" do
    # On some systems (macOS, Ubuntu) Asia/Saigon is directly recognized;
    # on others (Alpine Linux) it is not. Either way the service must
    # succeed and return a valid timezone.
    result = TimeZone::Normalize.call("Asia/Saigon")

    assert result.success?
    assert_includes ["Asia/Saigon", "Asia/Ho_Chi_Minh"], result.payload
    assert Time.find_zone(result.payload), "Expected payload to be a valid ActiveSupport timezone"
  end

  test "normalizes all known legacy zones to valid timezones" do
    TimeZone::Normalize::LEGACY_ZONES.each do |legacy, canonical|
      result = TimeZone::Normalize.call(legacy)

      assert result.success?, "Expected success for #{legacy}, got failure: #{result.error}"
      # The payload is either the legacy identifier (if the system recognizes
      # it directly) or the canonical equivalent from LEGACY_ZONES.
      assert_includes [legacy, canonical], result.payload
      assert Time.find_zone(result.payload), "Expected #{result.payload} to be recognized by ActiveSupport"
    end
  end

  test "returns failure for a completely invalid timezone" do
    result = TimeZone::Normalize.call("Invalid/Timezone")

    assert result.failure?
    assert_includes result.error, "Invalid timezone identifier"
  end

  test "returns success with Etc/UTC when given Etc/UTC" do
    result = TimeZone::Normalize.call("Etc/UTC")

    assert result.success?
    assert_equal "Etc/UTC", result.payload
  end

  test "returns success for common timezones" do
    %w[Europe/London Europe/Berlin Asia/Tokyo America/Sao_Paulo].each do |tz|
      result = TimeZone::Normalize.call(tz)

      assert result.success?, "Expected success for #{tz}, got failure: #{result.error}"
      assert_equal tz, result.payload
    end
  end
end
