# frozen_string_literal: true

require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @user.update(authentication_token: "test_token_123")
  end

  test "rekrei_api_kodon re-creates the api token for the user" do
    old_token = @user.authentication_token

    get api_v1_rekrei_api_kodon_url(id: @user.id),
      headers: {
        "X-User-Email" => @user.email,
        "X-User-Token" => @user.authentication_token
      }

    assert_redirected_to edit_user_registration_path

    @user.reload
    assert_not_equal old_token, @user.authentication_token
  end

  test "rekrei_api_kodon fails if id does not match user id" do
    old_token = @user.authentication_token
    other_user = create(:user)

    get api_v1_rekrei_api_kodon_url(id: other_user.id),
      headers: {
        "X-User-Email" => @user.email,
        "X-User-Token" => @user.authentication_token
      }

    assert_redirected_to root_url
    assert_equal "Vi ne rajtas fari tion.", flash[:error]

    @user.reload
    assert_equal old_token, @user.authentication_token
  end
end
