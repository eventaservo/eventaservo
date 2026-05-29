# frozen_string_literal: true

require "test_helper"

class FollowersControllerTest < ActionDispatch::IntegrationTest
  test "should toggle follow status for event" do
    user = create(:user)
    event = create(:event)
    sign_in user

    # Follow
    assert_difference -> { event.followers.count }, 1 do
      get event_toggle_follow_path(event_code: event.code)
    end

    assert_redirected_to root_url
    assert event.followers.exists?(user_id: user.id)

    # Unfollow
    assert_difference -> { event.followers.count }, -1 do
      get event_toggle_follow_path(event_code: event.code)
    end

    assert_redirected_to root_url
    assert_not event.followers.exists?(user_id: user.id)
  end

  test "should redirect if event not found" do
    sign_in create(:user)
    get event_toggle_follow_path(event_code: "invalid")
    assert_redirected_to root_url
    assert_equal "Event not found", flash[:alert]
  end

  test "should redirect to sign in if not authenticated" do
    event = create(:event)
    get event_toggle_follow_path(event_code: event.code)
    assert_redirected_to new_user_session_path
  end
end
