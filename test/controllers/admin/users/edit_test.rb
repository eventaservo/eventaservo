# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::EditTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @user = users(:user)
  end

  test "should get edit" do
    get edit_admin_user_url(@user)
    assert_response :success
  end
end
