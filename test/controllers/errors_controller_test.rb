# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get "/404"
    assert_response :not_found
  end

  test "should get unacceptable" do
    get "/422"
    assert_response :unprocessable_entity
  end

  test "should get internal_error" do
    get "/500"
    assert_response :internal_server_error
  end

  test "should post error_form and redirect" do
    # Mock the external Sentry API call
    sentry_url = "https://sentry.io/api/0/projects/#{Constants::SENTRY_ORGANIZATION_SLUG}/#{Constants::SENTRY_PROJECT_SLUG}/user-feedback/"
    stub_request(:post, sentry_url).to_return(status: 200, body: "", headers: {})

    assert_enqueued_emails 1 do
      post "/500", params: {
        sentry_event_id: "12345",
        name: "Test User",
        email: "test@example.com",
        comments: "This is a test error report."
      }
    end

    assert_redirected_to root_path
    assert_equal "Dankon!", flash[:notice]
  end
end
