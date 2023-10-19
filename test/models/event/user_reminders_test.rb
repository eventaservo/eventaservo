# frozen_string_literal: true

require "test_helper"

class Event::UserRemindersTest < ActiveSupport::TestCase
  setup do
    travel_to Time.zone.local(2023, 10, 21, 13, 0, 0)
  end

  test "enqueue 1 reminder-messages job when event happens before next week" do
    assert_enqueued_jobs 0
    event = FactoryBot.create(:evento, date_start: DateTime.now + 2.days, date_end: DateTime.now + 2.days)
    assert_enqueued_jobs 1
    assert 1, event.event_reminder_job_ids.size
  end

  test "enqueue 2 reminder-messages job when event happens before next month" do
    assert_enqueued_jobs 0
    event = FactoryBot.create(:evento, date_start: DateTime.now + 2.weeks, date_end: DateTime.now + 2.weeks)
    assert_enqueued_jobs 2
    assert 2, event.event_reminder_job_ids.size
  end

  test "enqueue 3 reminder-messages job when event happens after next month" do
    assert_enqueued_jobs 0
    event = FactoryBot.create(:evento, date_start: DateTime.now + 2.months, date_end: DateTime.now + 2.months)
    assert_enqueued_jobs 3
    assert 3, event.event_reminder_job_ids.size
  end
end
