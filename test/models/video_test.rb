# frozen_string_literal: true

# == Schema Information
#
# Table name: videos
#
#  id          :bigint           not null, primary key
#  description :string
#  title       :string
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#

require "test_helper"

class VideoTest < ActiveSupport::TestCase
  test "youtube? returns true when url contains youtube.com" do
    video = build(:video, url: "https://www.youtube.com/watch?v=123456")
    assert video.youtube?
  end

  test "youtube? returns true when url contains youtu.be" do
    video = build(:video, url: "https://youtu.be/123456")
    assert video.youtube?
  end

  test "youtube? returns false when url does not contain youtube domains" do
    video = build(:video, url: "https://example.com")
    assert_not video.youtube?
  end

  test "youtube_id returns id from youtube.com url" do
    video = build(:video, url: "https://www.youtube.com/watch?v=123456")
    assert_equal "123456", video.youtube_id
  end

  test "youtube_id returns id from youtu.be url" do
    video = build(:video, url: "https://youtu.be/123456")
    assert_equal "123456", video.youtube_id
  end

  test "youtube_id returns nil for non-youtube url" do
    video = build(:video, url: "https://example.com")
    assert_nil video.youtube_id
  end

  test "youtube_id returns id from youtube shorts url" do
    video = build(:video, url: "https://www.youtube.com/shorts/123456")
    assert_equal "123456", video.youtube_id
  end
end
