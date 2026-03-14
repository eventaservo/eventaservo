# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::ShowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @user = users(:user)
  end

  test "should get show" do
    get admin_user_url(@user)
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@user.name)}/
  end
end
