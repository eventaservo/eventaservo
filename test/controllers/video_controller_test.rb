require "test_helper"

class VideoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    video = create(:video)
    get video_url
    assert_response :success
    assert_match video.title, response.body
  end

  test "should create video" do
    event = create(:event)

    assert_difference("Video.count") do
      post event_new_video_url(event_code: event.code), params: {
        video_link: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        title: "Test Video",
        description: "This is a test video"
      }
    end

    assert_redirected_to event_url(code: event.code)

    video = Video.last
    assert_equal "Test Video", video.title
    assert_equal "This is a test video", video.description
    assert_equal event, video.evento
  end
end
