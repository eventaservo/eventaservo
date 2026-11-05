# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class ErrorsController::ErrorFormTest < ActionDispatch::IntegrationTest
  test "should post error_form and redirect with default locale flash notice" do
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

  test "should post error_form and redirect with localized flash notice in English when admin" do
    sign_in users(:admin_user)
    stub_request(:post, /sentry\.io/).to_return(status: 200)

    assert_enqueued_emails 1 do
      post "/en/500", params: {
        sentry_event_id: "123",
        name: "Test User",
        email: "test@example.com",
        comments: "Test error"
      }
    end

    assert_redirected_to root_path(locale: :en)
    assert_equal "Thank you!", flash[:notice]
  end

  test "should post error_form and redirect with localized flash notice in Portuguese when admin" do
    sign_in users(:admin_user)
    stub_request(:post, /sentry\.io/).to_return(status: 200)

    assert_enqueued_emails 1 do
      post "/pt_BR/500", params: {
        sentry_event_id: "123",
        name: "Test User",
        email: "test@example.com",
        comments: "Test error"
      }
    end

    assert_redirected_to root_path(locale: :pt_BR)
    assert_equal "Obrigado!", flash[:notice]
  end
end
