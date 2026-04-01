# frozen_string_literal: true

require "test_helper"

class Events::ContinentCountsQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "returns counts grouped by continent" do
    create_event(title: "Asian Event", country_id: 1, date_start: 1.week.from_now)   # Azio
    create_event(title: "European Event", country_id: 2, date_start: 1.week.from_now) # Eŭropo

    result = Events::ContinentCountsQuery.new(scope: Event.all).call

    continent_names = result.map(&:name)
    assert_includes continent_names, "Azio"
    assert_includes continent_names, "Eŭropo"
  end

  test "respects filters in the provided scope" do
    org = Organization.create!(name: "Test Org", short_name: "testorg", country_id: 1)
    event_with_org = create_event(title: "Org Event", country_id: 1, date_start: 1.week.from_now)
    create_event(title: "No Org Event", country_id: 1, date_start: 1.week.from_now)
    event_with_org.organizations << org

    filtered_scope = Event.joins(:organizations).where(organizations: {short_name: "testorg"})
    result = Events::ContinentCountsQuery.new(scope: filtered_scope).call
    azio = result.find { |c| c.name == "Azio" }

    assert_equal 1, azio.count
  end

  test "scope constraints like limit are fully applied before counting" do
    3.times { create_event(title: "Azio Event", country_id: 1, date_start: 1.week.from_now) }

    limited_scope = Event.where(country_id: 1).order(:id).limit(2)
    result = Events::ContinentCountsQuery.new(scope: limited_scope).call
    azio = result.find { |c| c.name == "Azio" }

    assert_equal 2, azio.count
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
