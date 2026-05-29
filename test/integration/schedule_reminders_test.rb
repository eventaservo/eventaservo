# frozen_string_literal: true

require "test_helper"

class ScheduleRemindersTest < ActionDispatch::IntegrationTest
  test "enqueue 1 reminder-messages job if event happens before next week" do
    assert_enqueued_jobs 1 do
      create(:evento, date_start: DateTime.now + 2.days, date_end: DateTime.now + 2.days)
    end
  end

  test "enqueue 2 reminder-messages job if event happens before next month" do
    assert_enqueued_jobs 2 do
      create(:evento, date_start: DateTime.now + 2.weeks, date_end: DateTime.now + 2.weeks)
    end
  end

  test "enqueue 3 reminder-messages job if event happens after next month" do
    assert_enqueued_jobs 3 do
      create(:evento, date_start: DateTime.now + 2.months, date_end: DateTime.now + 2.months)
    end
  end
end
