# frozen_string_literal: true

require "test_helper"

class EventRecurrences::GenerateChildrenTest < ActiveSupport::TestCase
  test "generates daily child events within horizon" do
    event = events(:esperanto_meetup)
    recurrence = EventRecurrence.create!(
      master_event: event,
      frequency: "daily",
      interval: 1,
      end_type: "never"
    )

    result = EventRecurrences::GenerateChildren.call(recurrence:)

    assert result.success?, result.error
    children = result.payload
    assert children.any?
    # Daily horizon is 7 days
    assert children.size <= 7

    children.each do |child|
      assert_equal event.title, child.title
      assert_equal event.user_id, child.user_id
      assert_equal event.id, child.recurrent_master_event_id
    end
  end

  test "generates weekly child events on specified days" do
    event = events(:esperanto_meetup)
    recurrence = EventRecurrence.create!(
      master_event: event,
      frequency: "weekly",
      interval: 1,
      days_of_week: [2, 4], # Tuesday, Thursday
      end_type: "never"
    )

    result = EventRecurrences::GenerateChildren.call(recurrence:)

    assert result.success?, result.error
    children = result.payload
    assert children.any?

    children.each do |child|
      wday = child.date_start.in_time_zone(event.time_zone).wday
      assert_includes [2, 4], wday, "Expected Tuesday(2) or Thursday(4), got #{wday}"
    end
  end

  test "does not duplicate existing child events" do
    event = events(:esperanto_meetup)
    recurrence = EventRecurrence.create!(
      master_event: event,
      frequency: "daily",
      interval: 1,
      end_type: "never"
    )

    # Generate once
    first_result = EventRecurrences::GenerateChildren.call(recurrence:)
    first_count = first_result.payload.size

    # Generate again — should not create duplicates
    second_result = EventRecurrences::GenerateChildren.call(recurrence: recurrence.reload)
    assert second_result.success?
    assert_equal 0, second_result.payload.size

    assert_equal first_count, event.recurrent_child_events.count
  end

  test "fails when recurrence is inactive" do
    recurrence = event_recurrences(:weekly_recurrence)
    recurrence.update!(active: false)

    result = EventRecurrences::GenerateChildren.call(recurrence:)
    assert result.failure?
  end

  test "child events preserve event duration" do
    event = events(:esperanto_meetup)
    original_duration = event.date_end - event.date_start

    recurrence = EventRecurrence.create!(
      master_event: event,
      frequency: "daily",
      interval: 1,
      end_type: "never"
    )

    result = EventRecurrences::GenerateChildren.call(recurrence:)
    assert result.success?

    result.payload.each do |child|
      child_duration = child.date_end - child.date_start
      assert_in_delta original_duration, child_duration, 1.second
    end
  end
end
