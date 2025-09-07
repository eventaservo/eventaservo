require "rails_helper"

RSpec.describe Events::Recurring::DatesCalculator, type: :calculator do
  let(:calculator) { described_class.new(recurrence:, months_ahead:) }
  let(:months_ahead) { 6 }

  describe "#next_dates" do
    subject { calculator.next_dates }

    before do
      stub_const("::Events::Recurring::GenerateEvents::MAX_EVENTS_PER_SERIES", 5)
    end

    context "when the recurrence is daily" do
      let(:master_event) { create(:event, date_start: Date.new(2025, 9, 7)) }
      let(:recurrence) { create(:event_recurrence, frequency: "daily", interval: 1, master_event:) }

      it "returns the next dates" do
        expected_dates = [
          Date.new(2025, 9, 8),
          Date.new(2025, 9, 9),
          Date.new(2025, 9, 10),
          Date.new(2025, 9, 11),
          Date.new(2025, 9, 12)
        ]
        expect(subject).to eq(expected_dates)
      end
    end

    context "when the recurrence is weekly" do
      let(:master_event) { create(:event, date_start: Date.new(2025, 9, 7)) }
      let(:recurrence) { create(:event_recurrence, frequency: "weekly", interval: 1, master_event:, days_of_week: [0, 3]) }

      it "returns the next dates" do
        expected_dates = [
          Date.new(2025, 9, 10),
          Date.new(2025, 9, 14),
          Date.new(2025, 9, 17),
          Date.new(2025, 9, 21),
          Date.new(2025, 9, 24)
        ]
        expect(subject).to eq(expected_dates)
      end
    end
  end
end
