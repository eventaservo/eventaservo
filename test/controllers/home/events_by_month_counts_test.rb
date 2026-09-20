# frozen_string_literal: true

require "test_helper"

# Verifies the private monthly event-count aggregation used by the home controller.
class HomeController::EventsByMonthCountsTest < ActionDispatch::IntegrationTest
  test "returns calendar labels and counts events in every month they span" do
    event = events(:valid_event)
    event.update!(date_start: Time.zone.parse("2026-01-31 18:00:00"), date_end: Time.zone.parse("2026-02-01 09:00:00"))

    result = HomeController.new.send(:events_by_month_counts)

    assert_equal %w[Jan Feb Mar Apr Maj Jun Jul Aŭg Sep Okt Nov Dec], result[:monatoj]
    assert_equal 12, result[:kvantoj].size
    assert_operator result[:kvantoj][0], :>=, 1
    assert_operator result[:kvantoj][1], :>=, 1
  end
end
