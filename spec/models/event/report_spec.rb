# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null, indexed
#  user_id    :bigint           not null, indexed
#
require "rails_helper"

RSpec.describe Event::Report, type: :model do
  describe "validations" do
    it "Factory should be valid" do
      expect(create(:event_report)).to be_truthy
    end

    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:event_id) }
    it { is_expected.to validate_presence_of(:user_id) }
  end

  describe "associations" do
    it { should belong_to(:event).inverse_of(:reports) }
    it { should belong_to(:user).inverse_of(:event_reports) }
  end

  describe "instance methods" do
    describe "#label" do
      it "should return title if present" do
        report = build_stubbed(:event_report, title: "foo")
        expect(report.label).to eq("foo")
      end

      it "should return url if title is blank" do
        report = build_stubbed(:event_report, title: nil, url: "http://example.com")
        expect(report.label).to eq("http://example.com")
      end
    end
  end

  describe "private methods" do
    describe "#convert_x_characters" do
      it "should remove the X characters from the title for new records" do
        report = create(:event_report, title: "Cxapelo")
        expect(report.title).to eq("Ĉapelo")
      end
    end

    describe "#validate_url_format" do
      it "should return false for bad urls" do
        bad_urls = %w[bad_url example.com /url]
        bad_urls.each do |bad_url|
          report = build_stubbed(:event_report, url: bad_url)
          expect(report.send(:validate_url_format)).to be_falsey
        end
      end

      it "should return true for good urls" do
        good_urls = %w[https://uea.org http://google.com]
        good_urls.each do |good_url|
          report = build_stubbed(:event_report, url: good_url)
          expect(report.send(:validate_url_format)).to be_truthy
        end
      end
    end
  end
end
