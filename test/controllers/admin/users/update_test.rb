# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::UpdateTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @user = users(:user)
  end

  test "should update user" do
    patch admin_user_url(@user), params: {user: {name: "Updated Name"}}
    assert_redirected_to admin_user_path(@user)
    assert_equal "Updated Name", @user.reload.name
  end

  test "should render edit on invalid update" do
    patch admin_user_url(@user), params: {user: {name: ""}}
    assert_response :unprocessable_entity
  end
end
