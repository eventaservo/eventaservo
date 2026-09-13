# frozen_string_literal: true

require "test_helper"

class Webcal::WebcalController::DispatcherTest < ActionDispatch::IntegrationTest
  test "user webcal redirects to root when user does not exist" do
    get webcal_user_url(webcal_token: "invalid_token")

    assert_redirected_to root_url
    assert_equal "Uzanto ne ekzistas", flash[:error]
  end
end
