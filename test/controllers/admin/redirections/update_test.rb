# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsController::UpdateTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @redirection = event_redirections(:one)
  end

  test "should update redirection" do
    patch admin_redirection_url(@redirection), params: {event_redirection: {new_short_url: "updated_new"}}
    assert_redirected_to admin_redirections_path
    @redirection.reload
    assert_equal "updated_new", @redirection.new_short_url
  end
end
