# frozen_string_literal: true

require "test_helper"

class Events::CountryCountsQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "returns counts grouped by country" do
    create_event(title: "Event in Afganio", country_id: 1, date_start: 1.week.from_now)
    create_event(title: "Event in Alando", country_id: 2, date_start: 1.week.from_now)

    result = Events::CountryCountsQuery.new(scope: Event.all).call

    country_names = result.map(&:name)
    assert_includes country_names, "Afganio"
    assert_includes country_names, "Alando"
  end

  test "includes code and continent columns" do
    create_event(title: "Event", country_id: 1, date_start: 1.week.from_now)

    result = Events::CountryCountsQuery.new(scope: Event.all).call
    country = result.find { |c| c.name == "Afganio" }

    assert_equal "af", country.code
    assert_equal "Azio", country.continent
  end

  test "respects filters in the provided scope" do
    create_event(title: "Future", country_id: 1, date_start: 1.week.from_now)
    create_event(title: "Past", country_id: 1, date_start: 2.months.ago, date_end: 2.months.ago + 2.hours)

    result = Events::CountryCountsQuery.new(scope: Event.venontaj).call
    afganio = result.find { |c| c.name == "Afganio" }

    venontaj_count = Event.venontaj.where(country_id: 1).count
    assert_equal venontaj_count, afganio.count
  end

  test "scope constraints like limit are fully applied before counting" do
    3.times { create_event(title: "Event", country_id: 1, date_start: 1.week.from_now) }

    limited_scope = Event.where(country_id: 1).order(:id).limit(2)
    result = Events::CountryCountsQuery.new(scope: limited_scope).call
    afganio = result.find { |c| c.name == "Afganio" }

    assert_equal 2, afganio.count
  end

  private

  # @param title [String]
  # @param country_id [Integer]
  # @param date_start [Time]
  # @param date_end [Time, nil]
  # @return [Event]
  def create_event(title:, country_id:, date_start:, date_end: nil)
    Event.create!(
      title: title,
      description: "Test event",
      city: "Test City",
      country_id: country_id,
      date_start: date_start,
      date_end: date_end || date_start + 2.hours,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://test.example.com",
      user: @user
    )
  end
end
