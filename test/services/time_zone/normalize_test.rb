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
    # On macOS, Asia/Saigon is directly recognized; on Linux it is not.
    # Either way the service must succeed and return a valid timezone.
    result = TimeZone::Normalize.call("Asia/Saigon")

    assert result.success?
    assert_includes ["Asia/Saigon", "Asia/Ho_Chi_Minh"], result.payload
    assert Time.find_zone(result.payload), "Expected payload to be a valid ActiveSupport timezone"
  end

  test "canonical_identifier resolves to a valid timezone for legacy zones" do
    # Verifies the TZInfo fallback path produces a usable result
    canonical = TZInfo::Timezone.get("Asia/Saigon").canonical_identifier

    assert Time.find_zone(canonical), "Expected #{canonical} to be recognized by ActiveSupport"
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
