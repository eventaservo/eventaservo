# frozen_string_literal: true

require "test_helper"

class EventRecurrences::CreateTest < ActiveSupport::TestCase
  test "creates recurrence and generates child events" do
    event = events(:esperanto_meetup)

    result = EventRecurrences::Create.call(
      event: event,
      recurrence_params: {
        frequency: "daily",
        interval: 1,
        end_type: "never"
      }
    )

    assert result.success?, result.error
    assert_kind_of EventRecurrence, result.payload
    assert event.reload.recurring_master?
    assert event.recurrent_child_events.any?
  end

  test "fails when event is already a recurring master" do
    event = events(:valid_event)  # has a recurrence via fixture

    result = EventRecurrences::Create.call(
      event: event,
      recurrence_params: {
        frequency: "daily",
        interval: 1,
        end_type: "never"
      }
    )

    assert result.failure?
    assert_equal "Event is already a recurring master", result.error
  end

  test "fails with invalid recurrence params" do
    event = events(:esperanto_meetup)

    result = EventRecurrences::Create.call(
      event: event,
      recurrence_params: {
        frequency: "weekly",
        interval: 1,
        end_type: "never"
        # Missing days_of_week
      }
    )

    assert result.failure?
  end
end
