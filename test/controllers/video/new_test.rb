require "test_helper"

class VideoController::NewTest < ActionDispatch::IntegrationTest
  test "should get new" do
    event = events(:valid_event)
    sign_in users(:user)
    get event_nova_video_url(event_code: event.code)
    assert_response :success
  end
end
