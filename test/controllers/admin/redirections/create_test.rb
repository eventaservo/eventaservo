# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsController::CreateTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
  end

  test "should create redirection" do
    assert_difference "EventRedirection.count", 1 do
      post admin_redirections_url, params: {event_redirection: {old_short_url: "new_old", new_short_url: "new_new"}}
    end
    assert_redirected_to admin_redirections_path
  end
end
