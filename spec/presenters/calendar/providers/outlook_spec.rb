require "rails_helper"

RSpec.describe Calendar::Providers::Outlook do
  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build(:event) }
    let(:provider) { :outlook }

    it "returns a valid Outlook Calendar URL" do
      expect(subject).to include("https://outlook.live.com/calendar/0/deeplink/compose")
    end
  end
end
