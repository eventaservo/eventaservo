# frozen_string_literal: true

require "test_helper"

# Verifies the private monthly event-count aggregation used by the home controller.
class HomeController::EventsByMonthCountsTest < ActionDispatch::IntegrationTest
  test "returns calendar labels and counts events in every month they span" do
    travel_to Time.zone.local(2026, 3, 15) do
      event = events(:valid_event)
      other_events = Event.where.not(id: event.id)
      # Every other fixture is pinned to one month, so the counts below depend only on the
      # event under test instead of on whatever months the remaining fixtures happen to
      # land in — without it, a lower bound would hold even when the spanning event is not
      # counted at all.
      other_events.update_all(date_start: Time.zone.parse("2026-03-10 10:00:00"),
        date_end: Time.zone.parse("2026-03-10 11:00:00"))

      # Spans two months: the last day of January and the first day of February.
      event.update!(date_start: Time.zone.parse("2026-01-31 18:00:00"),
        date_end: Time.zone.parse("2026-02-01 09:00:00"))

      result = HomeController.new.send(:events_by_month_counts)

      assert_equal %w[Jan Feb Mar Apr Maj Jun Jul Aŭg Sep Okt Nov Dec], result[:monatoj]
      assert_equal [1, 1, other_events.count, 0, 0, 0, 0, 0, 0, 0, 0, 0], result[:kvantoj]
    end
  end
end
