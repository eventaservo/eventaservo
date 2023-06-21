# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_event_reports_on_event_id  (event_id)
#  index_event_reports_on_user_id   (user_id)
#
require "test_helper"

class Event::ReportTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.build_stubbed(:user)
    @event = FactoryBot.build_stubbed(:event, user: @user)
    @report = FactoryBot.build_stubbed(:event_report, event: @event, user: @user)
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
end
