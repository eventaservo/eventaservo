# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @redirection = event_redirections(:one)
  end

  test "should get index" do
    get admin_redirections_url
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@redirection.old_short_url)}/
  end

  test "should filter by old url" do
    get admin_redirections_url, params: {old_url: @redirection.old_short_url}
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@redirection.old_short_url)}/

    get admin_redirections_url, params: {old_url: "nonexistent"}
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@redirection.old_short_url)}/, count: 0
  end

  test "should deny access to non-admin" do
    sign_out @admin
    sign_in users(:user)
    get admin_redirections_url
    assert_redirected_to root_path
  end
end
