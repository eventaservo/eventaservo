# frozen_string_literal: true

require "test_helper"

class Event::StartTimeLabelTest < ActiveSupport::TestCase
  test "formats the start time in the event time zone by default" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "America/Recife",
      date_start: Time.utc(2026, 5, 16, 12, 0)
    )

    assert_equal "09:00", event.start_time_label
  end

  test "uses the provided time zone instead of the event time zone" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "America/Recife",
      date_start: Time.utc(2026, 5, 16, 12, 0)
    )

    assert_equal "14:00", event.start_time_label(horzono: "Europe/Brussels")
  end
end
