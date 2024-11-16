require "rails_helper"

RSpec.describe Calendar::Providers::Google do
  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build(:event) }
    let(:provider) { :google }

    it "returns a valid Google Calendar URL" do
      expect(subject).to include("https://www.google.com/calendar/render?action=TEMPLATE")
    end
  end
end
