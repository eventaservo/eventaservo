# frozen_string_literal: true

require "test_helper"

class Event::ReportController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

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
end
