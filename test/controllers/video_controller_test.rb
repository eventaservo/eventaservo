require "test_helper"

class VideoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    video = create(:video)
    get video_url
    assert_response :success
    assert_match video.title, response.body
  end
end
