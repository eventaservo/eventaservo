# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::ResetPasswordTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @user = users(:user)
  end

  test "should reset user password" do
    patch reset_password_admin_user_url(@user)
    assert_redirected_to admin_user_path(@user)
  end
end
