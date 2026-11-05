# frozen_string_literal: true

require "test_helper"

class ErrorsController::InternalErrorTest < ActionDispatch::IntegrationTest
  test "should get internal_error in default locale (Esperanto)" do
    get "/500"
    assert_response :internal_server_error
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Oh! Eraro okazis!"
  end

  test "should get internal_error in English when admin user accesses localized route" do
    sign_in users(:admin_user)

    get "/en/500"
    assert_response :internal_server_error
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Oh! An error occurred!"
  end

  test "should get internal_error in Portuguese when admin user accesses localized route" do
    sign_in users(:admin_user)

    get "/pt_BR/500"
    assert_response :internal_server_error
    assert_equal "text/html", response.media_type
    assert_select "h1", text: "Ops! Ocorreu um erro!"
  end

  test "should get internal_error for JSON format" do
    get "/500.json"
    assert_response :internal_server_error
    assert_equal "application/json", response.media_type
    assert_equal "Internal Server Error", JSON.parse(response.body)["error"]
  end
end
