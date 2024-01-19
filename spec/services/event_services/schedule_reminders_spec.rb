require "rails_helper"

RSpec.describe EventServices::ScheduleReminders, type: :service do
  include ActiveJob::TestHelper

  let(:event) { create(:event, date_start: (Time.zone.now + 45.days), date_end: (Time.zone.now + 46.day)) }

  before { clear_enqueued_jobs }
  after { clear_enqueued_jobs }

  describe "#call" do
    subject { EventServices::ScheduleReminders.new(event).call }

    it "should set event_reminder_job_ids to the job ids" do
      event.update_column(:metadata, {"event_reminder_job_ids" => []})

      subject
      event.reload
      expect(event.event_reminder_job_ids.count).to eq(3)
    end

    it "event_reminder_job_ids should be UUIDs" do
      uuid_regex = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/
      subject

      event.event_reminder_job_ids.each do |job_id|
        expect(job_id).to match(uuid_regex)
      end
    end
  end
end
