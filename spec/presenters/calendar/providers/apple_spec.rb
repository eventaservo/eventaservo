require "rails_helper"

RSpec.describe Calendar::Providers::Apple do
  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build(:event) }
    let(:provider) { :apple }

    it "returns a valid Apple Calendar URL" do
      expect(subject).to include("/e/#{event.code}.ics")
    end
  end
end
