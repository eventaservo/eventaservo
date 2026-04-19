# frozen_string_literal: true

require "test_helper"

class Webcal::WebcalControllerTest < ActionDispatch::IntegrationTest
  test "user webcal redirects to root when user does not exist" do
    get webcal_user_url(webcal_token: "invalid_token")

    assert_redirected_to root_url
    assert_equal "Uzanto ne ekzisstas", flash[:error]
  end

  test "user webcal returns ics format for valid user" do
    user = users(:user)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)

    assert_response :success
    assert_equal "text/calendar; charset=utf-8", response.content_type
  end
end
