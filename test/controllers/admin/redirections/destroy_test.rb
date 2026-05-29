# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsController::DestroyTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @redirection = event_redirections(:one)
  end

  test "should destroy redirection" do
    assert_difference "EventRedirection.count", -1 do
      delete admin_redirection_url(@redirection)
    end
    assert_redirected_to admin_redirections_path
  end
end
