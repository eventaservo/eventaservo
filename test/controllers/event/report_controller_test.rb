require "test_helper"

class Event::ReportControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = FactoryBot.create(:user)
    @event = FactoryBot.create(:event, user: @user)
    @report = FactoryBot.create(:event_report, event: @event, user: @user)
  end

  class NewAction < Event::ReportControllerTest
    test "must be logged in to create a report" do
      get new_event_report_url(@event.code)
      assert_redirected_to new_user_session_url
    end

    test "should go to the new report page" do
      sign_in @user
      get new_event_report_url(@event.code)
      assert_response :success
    end
  end

  class CreateAction < Event::ReportControllerTest
    def setup
      @params = {event_report: {title: "title", url: "https://uea.org"}}
      super
    end

    test "must be logged in to create a report" do
      post event_reports_url(@event.code), params: @params
      assert_redirected_to new_user_session_url
    end

    test "should create a report" do
      sign_in @user
      assert_difference("Event::Report.count") do
        post event_reports_url(@event.code), params: @params
      end

      new_report = Event::Report.last

      assert_redirected_to event_url(@event.code)
      assert_equal @user, new_report.user
      assert_equal "title", new_report.title
      assert_equal "https://uea.org", new_report.url
    end
  end

  class DestroyAction < Event::ReportControllerTest
    test "must be logged in to destroy a report" do
      delete event_report_url(@event.code, @report)
      assert_redirected_to new_user_session_url
    end

    test "should destroy a report" do
      sign_in @user
      assert_difference("Event::Report.count", -1) do
        delete event_report_url(@event.code, @report)
      end
      assert_redirected_to event_url(@event.code)
    end
  end
end
