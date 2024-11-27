require "rails_helper"

RSpec.describe EventPresenter, type: :presenter do
  include Rails.application.routes.url_helpers

  describe ".add_to_calendar_links" do
    subject { described_class.new(event:).add_to_calendar_links }

    let(:event) { build_stubbed(:event) }

    it "has keys for the providers" do
      expect(subject.keys).to include(:ics)
      expect(subject.keys).to include(:google)
      expect(subject.keys).to include(:apple)
      expect(subject.keys).to include(:outlook)
      expect(subject.keys).to include(:yahoo)
    end
  end
end
