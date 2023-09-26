require "test_helper"

class UrlNormalizerTest < ActiveSupport::TestCase
  test "normalize url: google.com" do
    url = "google.com"
    assert_equal "https://google.com", UrlNormalizer.new(url).call
  end

  test "normalize url: http://google.com" do
    url = "http://google.com"
    assert_equal "http://google.com", UrlNormalizer.new(url).call
  end

  test "normalize url: https://google.com" do
    url = "https://google.com"
    assert_equal "https://google.com", UrlNormalizer.new(url).call
  end

  test "normalize url: https://google.com/" do
    url = "https://google.com/"
    assert_equal "https://google.com", UrlNormalizer.new(url).call
  end

  test "should return nil if url is nil" do
    assert_nil UrlNormalizer.new(nil).call
  end

  test "should return nil if is empty space" do
    assert_nil UrlNormalizer.new(" ").call
  end
end
