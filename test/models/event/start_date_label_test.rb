# frozen_string_literal: true

require "test_helper"

class Event::StartDateLabelTest < ActiveSupport::TestCase
  test "formats the start date in the event time zone by default" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "America/Recife",
      date_start: Time.utc(2026, 5, 16, 12, 0)
    )

    assert_equal "16/05/2026", event.start_date_label
  end

  test "uses the provided time zone instead of the event time zone" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "America/Recife",
      date_start: Time.utc(2026, 5, 16, 22, 0)
    )

    assert_equal "17/05/2026", event.start_date_label(horzono: "Europe/Brussels")
  end
end
