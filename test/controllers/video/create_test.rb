require "test_helper"

class VideoController::CreateTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:valid_event)
    @user = users(:user)
    @admin = users(:admin_user)
    @other_user = users(:teacher)
  end

  test "should create video when user is owner" do
    sign_in @user

    URI.stub(:open, StringIO.new) do
      assert_difference("Video.count") do
        post event_new_video_url(event_code: @event.code), params: {
          video_link: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          title: "Test Video",
          description: "This is a test video"
        }
      end
    end

    assert_redirected_to event_url(code: @event.code)

    video = Video.last
    assert_equal "Test Video", video.title
    assert_equal "This is a test video", video.description
    assert_equal @event, video.evento
  end

  test "should create video when user is admin" do
    sign_in @admin

    URI.stub(:open, StringIO.new) do
      assert_difference("Video.count") do
        post event_new_video_url(event_code: @event.code), params: {
          video_link: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          title: "Test Video",
          description: "This is a test video"
        }
      end
    end

    assert_redirected_to event_url(code: @event.code)
  end

  test "should not create video when user cannot edit event" do
    sign_in @other_user

    URI.stub(:open, StringIO.new) do
      assert_no_difference("Video.count") do
        post event_new_video_url(event_code: @event.code), params: {
          video_link: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          title: "Test Video",
          description: "This is a test video"
        }
      end
    end

    assert_redirected_to root_url
    assert_equal "Vi ne rajtas", flash[:error]
  end

  test "should not create video when not logged in" do
    URI.stub(:open, StringIO.new) do
      assert_no_difference("Video.count") do
        post event_new_video_url(event_code: @event.code), params: {
          video_link: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          title: "Test Video",
          description: "This is a test video"
        }
      end
    end

    assert_redirected_to new_user_session_url
  end
end
