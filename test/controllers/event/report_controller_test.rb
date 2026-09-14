# frozen_string_literal: true

require "test_helper"

class Event::ReportControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @event = create(:event)
    sign_in @user
  end

  # GET #index tests
  test "index eager loads report authors" do
    create_list(:event, 3).each do |event|
      create(:event_report, event:, user: create(:user))
    end

    ActiveRecord::Base.connection.clear_query_cache

    assert_queries_match(/FROM "event_reports"/i, count: 1) do
      assert_queries_match(/FROM "users"/i, count: 1) do
        get reports_path
      end
    end

    assert_response :success
  end

  # POST #create tests
  test "create enqueues NewEventReportNotificationJob" do
    params = {
      event_code: @event.code,
      event_report: {
        title: "Report title",
        url: "https://uea.org"
      }
    }

    assert_enqueued_with(job: NewEventReportNotificationJob) do
      post event_reports_path(event_code: @event.code), params: params
    end
  end

  test "create creates a Log record" do
    params = {
      event_code: @event.code,
      event_report: {
        title: "Report title",
        url: "https://uea.org"
      }
    }

    post event_reports_path(event_code: @event.code), params: params
    assert_equal "Report created", Log.last.text
    assert_equal Event::Report.last, Log.last.loggable
  end

  test "create redirects to event page" do
    params = {
      event_code: @event.code,
      event_report: {
        title: "Report title",
        url: "https://uea.org"
      }
    }

    post event_reports_path(event_code: @event.code), params: params
    assert_redirected_to event_path(code: @event.code)
  end

  test "create responds with unprocessable_entity when report is invalid" do
    params = {
      event_code: @event.code,
      event_report: {
        title: nil,
        url: "https://uea.org"
      }
    }

    post event_reports_path(event_code: @event.code), params: params
    assert_response :unprocessable_entity
  end

  # DELETE #destroy tests
  test "destroy removes the report" do
    report = create(:event_report, event: @event, user: @user)

    assert_difference("Event::Report.count", -1) do
      delete event_report_path(event_code: @event.code, id: report.id)
    end
  end
end
