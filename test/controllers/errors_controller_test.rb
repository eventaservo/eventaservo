# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get "/404"
    assert_response :not_found
    assert_match "<!DOCTYPE html>", response.body
  end

  test "should get not_found for js format" do
    get "/404.js"
    assert_response :not_found
    assert_equal "/* 404 Not Found */", response.body
    assert_equal "application/javascript; charset=utf-8", response.headers["Content-Type"]
  end

  test "should get not_found for css format" do
    get "/404.css"
    assert_response :not_found
    assert_equal "/* 404 Not Found */", response.body
    assert_equal "text/css; charset=utf-8", response.headers["Content-Type"]
  end

  test "should get not_found for other formats" do
    get "/404.json"
    assert_response :not_found
    assert_equal "404 Not Found", response.body
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
    stub_request(:post, /sentry\.io/).to_return(status: 200)

    assert_enqueued_emails 1 do
      post "/500", params: {
        sentry_event_id: "123",
        name: "Test User",
        email: "test@example.com",
        comments: "Test error"
      }
    end

    assert_redirected_to root_path
    assert_equal "Dankon!", flash[:notice]
  end
end
