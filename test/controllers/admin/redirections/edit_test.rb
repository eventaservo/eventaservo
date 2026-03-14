# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsController::EditTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @redirection = event_redirections(:one)
  end

  test "should get edit" do
    get edit_admin_redirection_url(@redirection)
    assert_response :success
  end
end
