require "test_helper"

module EventServicesTest
  class ScheduleRemindersTest < ActiveSupport::TestCase
    def setup
      @event = FactoryBot.create(:event, date_start: (Time.zone.now + 45.days), date_end: (Time.zone.now + 46.day))
    end

    test "#call should enqueue 3 reminders" do
      assert_enqueued_jobs 3 do
        EventServices::ScheduleReminders.new(@event).call
      end
    end

    test "#call should set event_reminder_job_ids to the job ids" do
      service = EventServices::ScheduleReminders.new(@event)
      service.delete_enqueued_jobs
      assert_equal [], @event.reload.event_reminder_job_ids

      service.call
      @event.reload
      assert_equal 3, @event.event_reminder_job_ids.count

      # Sidekiq job ids are UUIDs
      uuid_regex = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/
      @event.event_reminder_job_ids.each do |job_id|
        assert uuid_regex.match?(job_id)
      end
    end

    test "#delete_enqueued_jobs should set metadata['event_reminder_job_ids'] to []" do
      @event.update_column(:metadata, {"event_reminder_job_ids" => ["123", "456"]})

      EventServices::ScheduleReminders.new(@event).delete_enqueued_jobs
      assert_equal [], @event.reload.metadata["event_reminder_job_ids"]
    end
  end
end
