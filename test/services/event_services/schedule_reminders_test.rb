# frozen_string_literal: true

require "test_helper"

class EventServices::ScheduleRemindersTest < ActiveSupport::TestCase
  setup do
    @event = create(:event,
      date_start: (Time.zone.now + 45.days),
      date_end: (Time.zone.now + 46.days))
    clear_enqueued_jobs
  end

  teardown do
    clear_enqueued_jobs
  end

  test "sets event_reminder_job_ids to the job ids" do
    @event.update_column(:metadata, {"event_reminder_job_ids" => []})

    EventServices::ScheduleReminders.new(@event).call
    @event.reload

    assert_equal 3, @event.event_reminder_job_ids.count
  end

  test "event_reminder_job_ids should be UUIDs" do
    uuid_regex = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/

    EventServices::ScheduleReminders.new(@event).call

    @event.event_reminder_job_ids.each do |job_id|
      assert_match uuid_regex, job_id
    end
  end
end
