require "test_helper"

class Event::ReportTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.build_stubbed(:user)
    @event = FactoryBot.build_stubbed(:event, user: @user)
    @report = FactoryBot.build_stubbed(:event_report, event: @event, user: @user)
  end

  class Validations < Event::ReportTest
    test "should validate presence of url" do
      @report.url = nil
      assert_not @report.valid?
    end

    test "should validate presence of title" do
      @report.title = nil
      assert_not @report.valid?
    end

    test "should validate presence of event_id" do
      @report.event_id = nil
      assert_not @report.valid?
    end

    test "should validate presence of user_id" do
      @report.user_id = nil
      assert_not @report.valid?
    end
  end

  class ConvertXCharactersTest < Event::ReportTest
    test "on new record" do
      report = FactoryBot.create(:event_report, title: "Cxapelo", event: @event, user: @user)
      assert_equal "Ĉapelo", report.title
    end

    test "not on existing record" do
      report = FactoryBot.create(:event_report, title: "Ĉapelo", event: @event, user: @user)
      report.update(title: "Cxapelo")
      assert_equal "Cxapelo", report.title
    end
  end

  class LabelTest < Event::ReportTest
    test "#label should return title if present" do
      @report.title = "foo"
      assert_equal "foo", @report.label
    end

    test "#label should return url if title is blank" do
      @report.title = nil
      @report.url = "http://example.com"
      assert_equal "http://example.com", @report.label
    end
  end

  class UrlFormat < Event::ReportTest
    test "return false for bad urls" do
      bad_urls = %w[bad_url example.com /url]
      bad_urls.each do |bad_url|
        @report.url = bad_url
        assert_not @report.send(:validate_url_format)
      end
    end

    test "return true for good urls" do
      good_urls = %w[https://uea.org http://google.com]
      good_urls.each do |good_url|
        @report.url = good_url
        assert @report.send(:validate_url_format)
      end
    end
  end
end
