# frozen_string_literal: true

require "test_helper"

class EventsController::ByUsernameTest < ActionDispatch::IntegrationTest
  test "viewing a user with nil webcal_token succeeds without 500" do
    user = users(:user)
    user.update_column(:webcal_token, nil)

    get events_by_username_path(user.username)

    assert_response :success
    assert_select "#webcalModal", count: 0
    assert_select "a[aria-label='Aboni personan kalendaron']", count: 0
  end

  test "viewing another user profile does not render webcal modal or button" do
    user = users(:user)
    other_user = users(:admin_user)
    sign_in other_user

    get events_by_username_path(user.username)

    assert_response :success
    assert_select "#webcalModal", count: 0
    assert_select "a[aria-label='Aboni personan kalendaron']", count: 0
  end

  test "viewing own profile renders webcal modal and button" do
    user = users(:user)
    sign_in user

    get events_by_username_path(user.username)

    assert_response :success
    assert_select "#webcalModal", count: 1
    assert_select "a[aria-label='Aboni personan kalendaron']", count: 1
  end

  test "viewing own profile with nil webcal_token generates token and renders modal" do
    user = users(:user)
    user.update_column(:webcal_token, nil)
    sign_in user

    get events_by_username_path(user.username)

    assert_response :success
    assert_not_nil user.reload.webcal_token
    assert_select "#webcalModal", count: 1
    assert_select "a[aria-label='Aboni personan kalendaron']", count: 1
  end

  test "redirects to root with error when username does not exist" do
    get events_by_username_path("non_existent_username_xyz")

    assert_redirected_to root_path
    assert_equal "Uzantnomo ne ekzistas", flash[:error]
  end
end
