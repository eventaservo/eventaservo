# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::DeactivateTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should deactivate user" do
    user = users(:user)

    patch deactivate_admin_user_url(user)
    assert_redirected_to admin_user_path(user)
    assert user.reload.disabled?
  end
end
