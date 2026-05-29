# frozen_string_literal: true

require "test_helper"

class Events::CityCountsQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "returns counts grouped by city" do
    create_event(title: "Event A", city: "Parizo", date_start: 1.week.from_now)
    create_event(title: "Event B", city: "Parizo", date_start: 1.week.from_now)
    create_event(title: "Event C", city: "Berlino", date_start: 1.week.from_now)

    result = Events::CityCountsQuery.new(scope: Event.all).call

    parizo = result.find { |c| c.name == "Parizo" }
    berlino = result.find { |c| c.name == "Berlino" }

    assert_equal 2, parizo.count
    assert_equal 1, berlino.count
  end

  test "respects filters in the provided scope" do
    create_event(title: "Future", city: "Parizo", date_start: 1.week.from_now)
    create_event(title: "Past", city: "Parizo", date_start: 2.months.ago, date_end: 2.months.ago + 2.hours)

    result = Events::CityCountsQuery.new(scope: Event.venontaj).call
    parizo = result.find { |c| c.name == "Parizo" }

    venontaj_count = Event.venontaj.where(city: "Parizo").count
    assert_equal venontaj_count, parizo.count
  end

  test "scope constraints like limit are fully applied before counting" do
    3.times { create_event(title: "Event", city: "Tokio", date_start: 1.week.from_now) }

    limited_scope = Event.where(city: "Tokio").order(:id).limit(2)
    result = Events::CityCountsQuery.new(scope: limited_scope).call
    tokio = result.find { |c| c.name == "Tokio" }

    assert_equal 2, tokio.count
  end

  private

  # @param title [String]
  # @param city [String]
  # @param date_start [Time]
  # @param date_end [Time, nil]
  # @return [Event]
  def create_event(title:, city:, date_start:, date_end: nil)
    Event.create!(
      title: title,
      description: "Test event",
      city: city,
      country_id: 1,
      date_start: date_start,
      date_end: date_end || date_start + 2.hours,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://test.example.com",
      user: @user
    )
  end
end
