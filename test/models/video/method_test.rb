# frozen_string_literal: true

require "test_helper"

class Video::MethodTest < ActiveSupport::TestCase
  test "youtube? returns true when url contains youtube.com" do
    video = Video.new(url: "https://www.youtube.com/watch?v=123456")
    assert video.youtube?
  end

  test "youtube? returns true when url contains youtu.be" do
    video = Video.new(url: "https://youtu.be/123456")
    assert video.youtube?
  end

  test "youtube? returns false when url does not contain youtube domains" do
    video = Video.new(url: "https://example.com")
    assert_not video.youtube?
  end

  test "youtube_id returns id from youtube.com url" do
    video = Video.new(url: "https://www.youtube.com/watch?v=123456")
    assert_equal "123456", video.youtube_id
  end

  test "youtube_id returns id from youtu.be url" do
    video = Video.new(url: "https://youtu.be/123456")
    assert_equal "123456", video.youtube_id
  end

  test "youtube_id returns nil for non-youtube url" do
    video = Video.new(url: "https://example.com")
    assert_nil video.youtube_id
  end

  test "youtube_id returns id from youtube shorts url" do
    video = Video.new(url: "https://www.youtube.com/shorts/123456")
    assert_equal "123456", video.youtube_id
  end
end
