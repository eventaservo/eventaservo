require "rails_helper"

RSpec.describe Calendar::AddToCalendarPresenter, type: :presenter do
  include Rails.application.routes.url_helpers

  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build_stubbed(:event) }
    let(:provider) { :google }

    it "calls the url method for the provider class" do
      expect(Calendar::Providers::Google).to receive(:new).and_return(double(url: "https://google.com"))
      subject
    end
  end

  describe "#details" do
    subject { described_class.new(event:, provider:).details }

    let(:event) { build_stubbed(:event) }
    let(:provider) { :google }

    it "returns the details for the event" do
      expect(subject).to eq("#{event_url(code: event.code)}\n\n#{event.description}")
    end
  end

  describe "#location" do
    subject { described_class.new(event:, provider:).location }

    let(:provider) { :google }

    context "when the event has address" do
      let(:event) { build_stubbed(:event) }

      it "returns the address" do
        expect(subject).to eq(event.full_address)
      end
    end

    context "when the event doesn't have address" do
      let(:event) { build_stubbed(:event, :online) }

      it "returns the event url" do
        expect(subject).to eq(event_url(code: event.code))
      end
    end
  end
end
