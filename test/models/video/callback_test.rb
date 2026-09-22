# frozen_string_literal: true

require "test_helper"

class Video::CallbackTest < ActiveSupport::TestCase
  test "prefixes https:// when the url has no scheme" do
    video = Video.new(url: "www.youtube.com/watch?v=123456", evento: events(:valid_event))

    video.save

    assert_equal "https://www.youtube.com/watch?v=123456", video.url
  end

  test "strips surrounding whitespace from a url without a scheme" do
    video = Video.new(url: "  www.youtube.com/watch?v=123456  ", evento: events(:valid_event))

    video.save

    assert_equal "https://www.youtube.com/watch?v=123456", video.url
  end

  test "keeps an existing http:// url unchanged" do
    video = Video.new(url: "http://www.youtube.com/watch?v=123456", evento: events(:valid_event))

    video.save

    assert_equal "http://www.youtube.com/watch?v=123456", video.url
  end

  test "keeps an existing https:// url unchanged" do
    video = Video.new(url: "https://www.youtube.com/watch?v=123456", evento: events(:valid_event))

    video.save

    assert_equal "https://www.youtube.com/watch?v=123456", video.url
  end

  test "strips trailing whitespace from an http:// url" do
    video = Video.new(url: "http://www.youtube.com/watch?v=123456   ", evento: events(:valid_event))

    video.save

    assert_equal "http://www.youtube.com/watch?v=123456", video.url
  end
end
