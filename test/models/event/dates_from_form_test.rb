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

  test "round-trips the local wall-clock time the form re-renders without drift" do
    # The form re-renders +date_start+/+date_end+ as wall-clock strings in the
    # event's time zone (via +komenca_horo+). Resubmitting those values
    # unchanged must round-trip — local representation stays the same, and
    # the stored UTC stays the same — so a "no-change" save does not drift.
    event = events(:valid_event)
    event.update_columns(
      time_zone: "Europe/Brussels",
      date_start: Time.utc(2026, 5, 16, 12, 0), # 14:00 Brussels (CEST)
      date_end: Time.utc(2026, 5, 16, 17, 0)    # 19:00 Brussels (CEST)
    )

    event.dates_from_form = true
    event.assign_attributes(
      date_start: "2026-05-16 14:00",
      date_end: "2026-05-16 19:00"
    )
    event.save!

    assert_equal "14:00", event.date_start.in_time_zone("Europe/Brussels").strftime("%H:%M")
    assert_equal "19:00", event.date_end.in_time_zone("Europe/Brussels").strftime("%H:%M")
    assert_equal Time.utc(2026, 5, 16, 12, 0), event.date_start.utc
    assert_equal Time.utc(2026, 5, 16, 17, 0), event.date_end.utc
  end

  test "saves a wall-clock time on the spring-forward DST gap by shifting forward" do
    # Brussels skips 02:00→03:00 on 2026-03-29. A user typing "02:30" picks a
    # local time that doesn't exist; the model shifts it into 03:30 rather
    # than fail the save with a TZInfo::PeriodNotFound exception.
    event = events(:valid_event)
    event.dates_from_form = true
    event.assign_attributes(
      time_zone: "Europe/Brussels",
      date_start: "2026-03-29 02:30",
      date_end: "2026-03-29 04:30"
    )
    event.save!

    assert_equal "03:30", event.date_start.in_time_zone("Europe/Brussels").strftime("%H:%M")
    assert_equal "04:30", event.date_end.in_time_zone("Europe/Brussels").strftime("%H:%M")
  end

  test "saves a wall-clock time on the fall-back DST overlap using the DST offset" do
    # Brussels falls back 03:00→02:00 on 2026-10-25. The local 02:30 happens
    # twice; the model deterministically picks the DST (summer-time)
    # occurrence so the form value the user sees round-trips after save.
    event = events(:valid_event)
    event.dates_from_form = true
    event.assign_attributes(
      time_zone: "Europe/Brussels",
      date_start: "2026-10-25 02:30",
      date_end: "2026-10-25 04:30"
    )
    event.save!

    assert_equal "02:30", event.date_start.in_time_zone("Europe/Brussels").strftime("%H:%M")
    assert_equal "04:30", event.date_end.in_time_zone("Europe/Brussels").strftime("%H:%M")
    # DST occurrence of 02:30 Brussels = 00:30 UTC; standard offset would be 01:30 UTC.
    assert_equal Time.utc(2026, 10, 25, 0, 30), event.date_start.utc
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
