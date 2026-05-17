require "test_helper"

class VideoController::IndexTest < ActionDispatch::IntegrationTest
  test "should get index" do
    video = videos(:rails_conference_video)
    get video_url
    assert_response :success
    assert_match video.title, response.body
  end
end
