# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::MergeTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @user = users(:user)
  end

  test "should get merge page" do
    get merge_admin_user_url(@user)
    assert_response :success
  end
end
