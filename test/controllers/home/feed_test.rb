# frozen_string_literal: true

require "test_helper"

class HomeController::FeedTest < ActionDispatch::IntegrationTest
  test "should get feed as xml" do
    get events_rss_url
    assert_response :success
    assert_equal "application/xml", response.media_type
  end

  test "should not get feed as md" do
    # When requesting unsupported format, should return 406 Not Acceptable
    get events_rss_url(format: :md)
    assert_response :not_acceptable
  end

  test "should not get feed as html" do
    get events_rss_url(format: :html)
    assert_response :not_acceptable
  end
end
