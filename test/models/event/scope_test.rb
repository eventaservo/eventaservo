# frozen_string_literal: true

require "test_helper"

class Event::ScopeTest < ActiveSupport::TestCase
  test "venontaj with New York tz includes event ending on the previous UTC day" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 03:00:00") do
        event = create_event_ending_at("2026-08-14 23:00:00")

        assert_includes Event.venontaj("America/New_York"), event
        assert_not_includes Event.venontaj, event
      end
    end
  end

  test "today with New York tz includes event at 20:00 EDT that is 00:00 UTC next day" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-14 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-15 01:00:00"),
          time_zone: "America/New_York"
        )

        assert_includes Event.today("America/New_York"), event
        assert_not_includes Event.today, event
      end
    end
  end

  test "today without tz keeps UTC behavior" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-14 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-14 23:00:00"),
          date_end: Time.zone.parse("2026-08-14 23:30:00"),
          time_zone: "America/New_York"
        )

        assert_includes Event.today, event
        assert_includes Event.today("America/New_York"), event
      end
    end
  end

  test "not_today with New York tz excludes event that is already next day in UTC" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-14 12:00:00") do
        event = create(
          :event,
          date_start: Time.zone.parse("2026-08-15 00:00:00"),
          date_end: Time.zone.parse("2026-08-15 01:00:00"),
          time_zone: "America/New_York"
        )

        assert_not_includes Event.not_today("America/New_York"), event
        assert_includes Event.not_today, event
      end
    end
  end

  test "not_cancelled returns only events that have not been cancelled" do
    cancelled = create(:event, cancelled: true)
    active = create(:event, cancelled: false)

    result = Event.not_cancelled

    assert_includes result, active
    assert_not_includes result, cancelled
  end

  test "by_organization returns events associated with the given organization short_name" do
    organization = Organization.create!(name: "Modern Org", short_name: "modernorg", country_id: 1)
    matching = create(:event)
    other = create(:event)
    matching.organizations << organization

    result = Event.by_organization("modernorg")

    assert_includes result, matching
    assert_not_includes result, other
  end

  test "by_organization matches multiple comma-separated short names case-insensitively" do
    first = Organization.create!(name: "First Org", short_name: "FIRSTorg", country_id: 1)
    second = Organization.create!(name: "Second Org", short_name: "SecondOrg", country_id: 1)
    first_event = create(:event)
    second_event = create(:event)
    other = create(:event)
    first_event.organizations << first
    second_event.organizations << second

    result = Event.by_organization("FIRSTORG,secondorg")

    assert_includes result, first_event
    assert_includes result, second_event
    assert_not_includes result, other
  end

  test "by_organization composes with other scopes" do
    organization = Organization.create!(name: "Modern Org", short_name: "modernorg", country_id: 1)
    cancelled = create(:event, cancelled: true)
    active = create(:event)
    cancelled.organizations << organization
    active.organizations << organization

    result = Event.not_cancelled.by_organization("modernorg")

    assert_includes result, active
    assert_not_includes result, cancelled
  end

  test "venontaj excludes events from the previous UTC day" do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2026-08-15 03:59:00") do
        event = create_event_ending_at("2026-08-14 23:59:00")

        assert_not_includes Event.venontaj, event
      end
    end
  end

  private

  # Creates an event with a fixed end time for scope boundary tests.
  #
  # @param date_end [String] UTC end time
  # @return [Event]
  def create_event_ending_at(date_end)
    end_time = Time.zone.parse(date_end)

    create(
      :event,
      date_start: end_time - 1.hour,
      date_end: end_time
    )
  end
end
