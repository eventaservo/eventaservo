require "rails_helper"

RSpec.describe Calendar::Providers::Yahoo do
  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build(:event) }
    let(:provider) { :yahoo }

    it "returns a valid Yahoo Calendar URL" do
      expect(subject).to include("https://calendar.yahoo.com/")
    end
  end
end
