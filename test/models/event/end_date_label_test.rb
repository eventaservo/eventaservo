# frozen_string_literal: true

require "test_helper"

class Event::EndDateLabelTest < ActiveSupport::TestCase
  test "formats the end date in the event time zone by default" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "America/Recife",
      date_end: Time.utc(2026, 5, 16, 12, 0)
    )

    assert_equal "16/05/2026", event.end_date_label
  end

  test "uses the provided time zone instead of the event time zone" do
    event = events(:valid_event)
    event.update_columns(
      time_zone: "America/Recife",
      date_end: Time.utc(2026, 5, 16, 22, 0)
    )

    assert_equal "17/05/2026", event.end_date_label(horzono: "Europe/Brussels")
  end

  test "returns nil when the event has no end date" do
    event = events(:valid_event)
    event.update_columns(date_end: nil)

    assert_nil event.end_date_label
  end
end
