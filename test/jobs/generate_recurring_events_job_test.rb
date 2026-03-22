# frozen_string_literal: true

require "test_helper"

class GenerateRecurringEventsJobTest < ActiveSupport::TestCase
  test "processes all active recurrences" do
    recurrence = event_recurrences(:weekly_recurrence)
    assert recurrence.active?

    assert_nothing_raised do
      GenerateRecurringEventsJob.perform_now
    end

    # Should have generated child events
    assert recurrence.master_event.recurrent_child_events.any?
  end

  test "skips inactive recurrences gracefully" do
    recurrence = event_recurrences(:weekly_recurrence)
    recurrence.update!(active: false)

    assert_nothing_raised do
      GenerateRecurringEventsJob.perform_now
    end
  end
end
