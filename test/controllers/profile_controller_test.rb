# frozen_string_literal: true

require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  # GET #events tests
  test "events returns success for authenticated user viewing own profile" do
    get profile_events_path(username: @user.username)
    assert_response :success
  end

  test "events redirects to root when username is unknown" do
    get profile_events_path(username: "unknown")

    assert_redirected_to root_path
    assert_not_nil flash[:error]
  end

  test "events redirects to root when user is not the profile user" do
    another_user = create(:user)
    get profile_events_path(username: another_user.username)

    assert_redirected_to root_path
    assert_not_nil flash[:error]
  end
end
