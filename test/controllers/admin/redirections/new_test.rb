# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsController::NewTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should get new" do
    get new_admin_redirection_url
    assert_response :success
  end
end
