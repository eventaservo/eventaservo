# frozen_string_literal: true

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

require "test_helper"

class Event::ReportTest < ActiveSupport::TestCase
  test "Factory should be valid" do
    assert create(:event_report)
  end

  test "should validate presence of url" do
    report = Event::Report.new
    assert_not report.valid?
    assert_includes report.errors[:url], "devas esti kompletigita"
  end

  test "should validate presence of title" do
    report = Event::Report.new
    assert_not report.valid?
    assert_includes report.errors[:title], "devas esti kompletigita"
  end

  test "should validate presence of event_id" do
    report = Event::Report.new
    assert_not report.valid?
    assert_includes report.errors[:event_id], "devas esti kompletigita"
  end

  test "should validate presence of user_id" do
    report = Event::Report.new
    assert_not report.valid?
    assert_includes report.errors[:user_id], "devas esti kompletigita"
  end

  test "should belong to event" do
    report = Event::Report.new
    assert_respond_to report, :event
  end

  test "should belong to user" do
    report = Event::Report.new
    assert_respond_to report, :user
  end

  test "label should return title if present" do
    report = build(:event_report, title: "foo")
    assert_equal "foo", report.label
  end

  test "label should return url if title is blank" do
    report = build(:event_report, title: nil, url: "http://example.com")
    assert_equal "http://example.com", report.label
  end

  test "should remove the X characters from the title for new records" do
    report = create(:event_report, title: "Cxapelo")
    assert_equal "Ĉapelo", report.title
  end

  test "validate_url_format should return false for bad urls" do
    bad_urls = %w[bad_url example.com /url]
    bad_urls.each do |bad_url|
      report = build(:event_report, url: bad_url)
      assert_not report.send(:validate_url_format)
    end
  end

  test "validate_url_format should return true for good urls" do
    good_urls = %w[https://uea.org http://google.com]
    good_urls.each do |good_url|
      report = build(:event_report, url: good_url)
      assert report.send(:validate_url_format)
    end
  end
end
