require "rails_helper"

RSpec.describe Calendar::Providers::IcsFile do
  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build(:event) }
    let(:provider) { :ics_file }

    it "returns a valid ICS file to download" do
      expect(subject).to include("/e/#{event.code}.ics")
    end
  end
end
