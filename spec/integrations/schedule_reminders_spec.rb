require "rails_helper"

RSpec.describe "Schedule reminders" do
  include ActiveJob::TestHelper

  describe "when an event is created" do
    it "should enqueue 1 reminder-messages job if event happens before next week" do
      expect {
        create(:evento, date_start: DateTime.now + 2.days, date_end: DateTime.now + 2.days)
      }.to change { enqueued_jobs.size }.by(1)
    end

    it "should enqueue 2 reminder-messages job if event happens before next month" do
      expect {
        create(:evento, date_start: DateTime.now + 2.weeks, date_end: DateTime.now + 2.weeks)
      }.to change { enqueued_jobs.size }.by(2)
    end

    it "should enqueue 3 reminder-messages job if event happens after next month" do
      expect {
        create(:evento, date_start: DateTime.now + 2.months, date_end: DateTime.now + 2.months)
      }.to change { enqueued_jobs.size }.by(3)
    end
  end
end
