# frozen_string_literal: true

require "test_helper"

class ErrorsController::UnacceptableTest < ActionDispatch::IntegrationTest
  test "should get unacceptable in default locale (Esperanto)" do
    get "/422"
    assert_response :unprocessable_entity
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Neakceptebla peto"
  end

  test "should get unacceptable in English when admin user accesses localized route" do
    sign_in users(:admin_user)

    get "/en/422"
    assert_response :unprocessable_entity
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Unacceptable request"
  end

  test "should get unacceptable in Portuguese when admin user accesses localized route" do
    sign_in users(:admin_user)

    get "/pt_BR/422"
    assert_response :unprocessable_entity
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Solicitação inaceitável"
  end

  test "should get unacceptable for JSON format" do
    get "/422.json"
    assert_response :unprocessable_entity
    assert_equal "application/json", response.media_type
    assert_equal "Unprocessable Entity", JSON.parse(response.body)["error"]
  end
end
