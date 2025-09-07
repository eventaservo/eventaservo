# frozen_string_literal: true

require "rails_helper"

RSpec.describe Events::Recurring::Create, type: :service do
  describe ".call" do
    subject { described_class.call(**kwargs) }

    let(:kwargs) { {master_event:, day_of_month:, days_of_week:, end_date:, end_type:, frequency:, interval:} }
    let(:day_of_month) { 15 }
    let(:days_of_week) { nil }
    let(:end_date) { 6.months.from_now.to_date }
    let(:end_type) { "on_date" }
    let(:frequency) { "monthly" }
    let(:interval) { 1 }

    let(:master_event) do
      create(:event, date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours, is_recurring_master: false)
    end

    context "with valid parameters" do
      it "returns success with a EventRecurrence object" do
        result = subject

        expect(result.success?).to be true
        expect(result.payload).to be_a(EventRecurrence)
      end

      it "sets master event as recurring master" do
        expect { subject }.to change(master_event, :is_recurring_master).from(false).to(true)
      end

      it "creates the EventRecurrence object with correct attributes" do
        result = subject
        recurrence = result.payload

        expect(recurrence.master_event).to eq(master_event)
        expect(recurrence.frequency).to eq("monthly")
        expect(recurrence.interval).to eq(1)
        expect(recurrence.end_type).to eq("on_date")
        expect(recurrence.end_date).to eq(6.months.from_now.to_date)
        expect(recurrence.active).to be true
      end
    end

    context "with days_of_week for weekly recurrence" do
      let(:days_of_week) { [1, 3, 5] }

      it "creates recurrence with specific days of week" do
        recurrence = subject.payload

        expect(recurrence.days_of_week).to eq([1, 3, 5])
      end
    end

    context "with daily frequency" do
      let(:frequency) { "daily" }
      let(:interval) { 2 }

      it "creates daily recurrence with interval" do
        recurrence = subject.payload

        expect(recurrence.frequency).to eq("daily")
        expect(recurrence.interval).to eq(2)
      end
    end

    context "when master_event is already a recurring master" do
      before do
        master_event.update!(is_recurring_master: true)
      end

      it "returns failure with message" do
        result = subject

        expect(result.failure?).to be true
        expect(result.error).to be_present
      end
    end

    context "when master_event already has a recurrence" do
      before do
        create(:event_recurrence, master_event: master_event)
      end

      it "returns failure with message" do
        result = subject

        expect(result.failure?).to be true
        expect(result.error).to be_present
      end
    end

    context "with invalid data" do
      let(:frequency) { "invalid_frequency" }

      it "returns failure with message" do
        result = subject

        expect(result.failure?).to be true
        expect(result.error).to be_present
      end
    end

    context "with nil master_event" do
      let(:master_event) { nil }

      it "fails validation" do
        result = subject

        expect(result.failure?).to be true
        expect(result.error).to be_present
      end
    end
  end
end
