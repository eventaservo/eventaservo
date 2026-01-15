require "rails_helper"

RSpec.describe Calendar::Providers::Google do
  describe "#url" do
    subject { described_class.new(event:, provider:).url }

    let(:event) { build(:event) }
    let(:provider) { :google }

    it "returns a valid Google Calendar URL" do
      expect(subject).to include("https://www.google.com/calendar/render?action=TEMPLATE")
    end

    context "when dealing with timezones" do
      let(:event) do
        build(:event,
          date_start: Time.zone.parse("2024-01-15 15:00:00 UTC"),
          date_end: Time.zone.parse("2024-01-15 16:00:00 UTC"),
          time_zone: "America/Sao_Paulo")
      end

      it "converts timestamps to UTC in the dates parameter" do
        expect(subject).to include("dates=20240115T150000Z%2F20240115T160000Z")
      end

      it "includes the Z suffix to indicate UTC" do
        expect(subject).to match(/dates=\d{8}T\d{6}Z/)
      end
    end

    context "with event in different timezone" do
      let(:event) do
        build(:event,
          date_start: Time.zone.parse("2024-06-20 14:00:00 UTC"),
          date_end: Time.zone.parse("2024-06-20 15:30:00 UTC"),
          time_zone: "Europe/Madrid")
      end

      it "uses UTC timestamps regardless of event timezone" do
        expect(subject).to include("dates=20240620T140000Z%2F20240620T153000Z")
      end
    end

    context "with event in UTC timezone" do
      let(:event) do
        build(:event,
          date_start: Time.zone.parse("2024-03-10 10:00:00 UTC"),
          date_end: Time.zone.parse("2024-03-10 11:00:00 UTC"),
          time_zone: "Etc/UTC")
      end

      it "maintains UTC timestamps correctly" do
        expect(subject).to include("dates=20240310T100000Z%2F20240310T110000Z")
      end
    end
  end
end
