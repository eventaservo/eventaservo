# frozen_string_literal: true

require "test_helper"

class Event::DatesFromFormTest < ActiveSupport::TestCase
  test "preserves wall-clock hour when typed value collides with stored UTC hour" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "Europe/Brussels",
      date_start: Time.utc(2026, 5, 16, 12, 0),
      date_end: Time.utc(2026, 5, 16, 17, 0)
    )

    event.dates_from_form = true
    event.assign_attributes(
      date_start: "2026-05-16 12:00",
      date_end: "2026-05-16 17:00"
    )
    event.save!

    assert_equal "12:00", event.date_start.in_time_zone("Europe/Brussels").strftime("%H:%M")
    assert_equal "17:00", event.date_end.in_time_zone("Europe/Brussels").strftime("%H:%M")
  end

  test "preserves wall-clock hour when time zone changes during the same save" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "Europe/Brussels",
      date_start: Time.utc(2026, 5, 16, 10, 0),
      date_end: Time.utc(2026, 5, 16, 15, 0)
    )

    event.dates_from_form = true
    event.assign_attributes(
      date_start: "2026-05-16 12:00",
      date_end: "2026-05-16 17:00",
      time_zone: "America/Recife"
    )
    event.save!

    assert_equal "America/Recife", event.time_zone
    assert_equal "12:00", event.date_start.in_time_zone(event.time_zone).strftime("%H:%M")
    assert_equal "17:00", event.date_end.in_time_zone(event.time_zone).strftime("%H:%M")
  end

  test "is a no-op when user resubmits the same wall-clock time without changing it" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "Europe/Brussels",
      date_start: Time.utc(2026, 5, 16, 12, 0),
      date_end: Time.utc(2026, 5, 16, 17, 0)
    )

    event.dates_from_form = true
    event.assign_attributes(
      date_start: "2026-05-16 14:00",
      date_end: "2026-05-16 19:00"
    )
    event.save!

    assert_equal Time.utc(2026, 5, 16, 12, 0), event.date_start.utc
    assert_equal Time.utc(2026, 5, 16, 17, 0), event.date_end.utc
  end

  test "skips reinterpretation when dates_from_form flag is not set" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "Europe/Brussels",
      date_start: Time.utc(2026, 5, 16, 12, 0),
      date_end: Time.utc(2026, 5, 16, 17, 0)
    )

    event.assign_attributes(
      date_start: Time.utc(2026, 5, 16, 9, 0),
      date_end: Time.utc(2026, 5, 16, 14, 0)
    )
    event.save!

    assert_equal Time.utc(2026, 5, 16, 9, 0), event.date_start.utc
    assert_equal Time.utc(2026, 5, 16, 14, 0), event.date_end.utc
  end
end
