# frozen_string_literal: true

require "test_helper"

class Admin::UsersController::EnableTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should enable disabled user" do
    user = users(:user)
    user.update_column(:disabled, true)

    patch enable_admin_user_url(user)
    assert_redirected_to admin_user_path(user)
    assert_not user.reload.disabled?
  end
end
