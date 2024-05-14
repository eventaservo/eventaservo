require "rails_helper"

RSpec.describe UrlLanguageChanger, type: :service do
  describe "#call" do
    subject(:service) { described_class.new(url, locale) }

    let(:locale) { "en" }

    context "when the URL does not have a defined language" do
      context "and there are no paths in the URL" do
        let(:url) { "http://eventaservo.org" }

        it "adds the locale to the URL" do
          expect(service.call).to eq("http://eventaservo.org/en")
        end
      end

      context "and there are other paths in the URL" do
        let(:url) { "http://eventaservo.org/e/12345" }

        it "adds the locale to the URL without removing the other paths" do
          expect(service.call).to eq("http://eventaservo.org/en/e/12345")
        end
      end
    end

    context "when the URL has a defined language" do
      context "and there are no paths in the URL" do
        let(:url) { "http://eventaservo.org/eo" }

        it "changes the language" do
          expect(service.call).to eq("http://eventaservo.org/en")
        end
      end

      context "and there are other paths in the URL" do
        let(:url) { "http://eventaservo.org/eo/e/12345" }

        it "changes the language without removing the other paths" do
          expect(service.call).to eq("http://eventaservo.org/en/e/12345")
        end
      end
    end
  end
end
