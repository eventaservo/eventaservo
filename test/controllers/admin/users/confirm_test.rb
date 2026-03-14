# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::ConfirmTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should confirm user email" do
    user = users(:user)
    user.update_column(:confirmed_at, nil)

    patch confirm_admin_user_url(user)
    assert_redirected_to admin_user_path(user)
    assert_not_nil user.reload.confirmed_at
  end
end
