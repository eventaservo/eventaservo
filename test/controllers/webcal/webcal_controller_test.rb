# frozen_string_literal: true

require "test_helper"

class WebcalControllerTest < ActionDispatch::IntegrationTest
  test "Nevalida lando devas montri la ĉefpaĝon" do
    get webcal_url(landa_kodo: "ne_valida_landa_kodo", format: :ics)
    assert_redirected_to root_url
  end

  test "Valida landa kono devas montri eventojn" do
    get webcal_url(landa_kodo: "br", format: :ics)
    assert_response :success
  end

  test "redirects to root page if webcal_token is invalid" do
    get webcal_user_url(webcal_token: "invalid", format: :ics)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "respond success if the webcal_token valids an user" do
    user = FactoryBot.create(:user)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)
    assert_response :success
  end
end
