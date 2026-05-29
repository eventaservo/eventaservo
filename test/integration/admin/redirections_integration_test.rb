# frozen_string_literal: true

require "test_helper"

class Admin::RedirectionsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @redirection = event_redirections(:one)
  end

  test "full redirection management flow" do
    # 1. Index
    get admin_redirections_path
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@redirection.old_short_url)}/

    # 2. Filter
    get admin_redirections_path, params: {old_url: @redirection.old_short_url}
    assert_response :success
    assert_select "div", text: /#{Regexp.escape(@redirection.old_short_url)}/

    # 3. New/Create
    get new_admin_redirection_path
    assert_response :success
    assert_difference "EventRedirection.count", 1 do
      post admin_redirections_path, params: {event_redirection: {old_short_url: "brand_new", new_short_url: "brand_target"}}
    end
    assert_redirected_to admin_redirections_path
    follow_redirect!
    assert_select "div", text: /brand_new/

    # 4. Edit/Update
    red = EventRedirection.find_by(old_short_url: "brand_new")
    get edit_admin_redirection_path(red)
    assert_response :success
    patch admin_redirection_path(red), params: {event_redirection: {new_short_url: "updated_target"}}
    assert_redirected_to admin_redirections_path
    red.reload
    assert_equal "updated_target", red.new_short_url

    # 5. Delete (The reported problematic part)
    assert_difference "EventRedirection.count", -1 do
      delete admin_redirection_path(red)
    end
    assert_redirected_to admin_redirections_path
    follow_redirect!
    assert_select "div", text: /brand_new/, count: 0
  end
end
