require "test_helper"

class FollowersControllerTest < ActionDispatch::IntegrationTest
  test "should toggle follow status for event" do
    user = create(:user)
    event = create(:event)
    sign_in user

    # Follow
    assert_difference "event.followers.count", 1 do
      get event_toggle_follow_path(event_code: event.code)
    end

    assert_redirected_to root_url

    # Unfollow
    assert_difference "event.followers.count", -1 do
      get event_toggle_follow_path(event_code: event.code)
    end

    assert_redirected_to root_url
  end
end
