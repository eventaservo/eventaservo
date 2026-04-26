# frozen_string_literal: true

require "test_helper"

class Country::DefaultTimeZoneTest < ActiveSupport::TestCase
  test "returns the IANA identifier TZInfo lists first for a single-timezone country" do
    netherlands = countries(:country_150)
    expected = TZInfo::Country.get("NL").zone_identifiers.first

    assert_equal expected, netherlands.default_time_zone
    assert ActiveSupport::TimeZone[netherlands.default_time_zone],
      "Expected TZInfo identifier to be a recognized ActiveSupport::TimeZone"
  end

  test "returns the first IANA identifier for a multi-timezone country" do
    usa = countries(:country_234)
    identifiers = TZInfo::Country.get("US").zone_identifiers

    assert_equal identifiers.first, usa.default_time_zone
  end

  test "returns nil for the synthetic online country" do
    online = countries(:country_99999)

    assert_nil online.default_time_zone
  end

  test "returns nil when the country code is blank" do
    country = Country.new(name: "Sennoma", continent: "Eŭropo", code: nil)

    assert_nil country.default_time_zone
  end

  test "returns nil when the ISO code is unknown to TZInfo" do
    country = Country.new(name: "Sennoma", continent: "Eŭropo", code: "zz")

    assert_nil country.default_time_zone
  end
end
