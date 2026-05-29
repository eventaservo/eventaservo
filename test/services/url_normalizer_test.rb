# frozen_string_literal: true

require "test_helper"

class UrlNormalizerTest < ActiveSupport::TestCase
  test "normalizes url without protocol" do
    assert_equal "https://google.com", UrlNormalizer.new("google.com").call
  end

  test "preserves http protocol" do
    assert_equal "http://google.com", UrlNormalizer.new("http://google.com").call
  end

  test "preserves https protocol" do
    assert_equal "https://google.com", UrlNormalizer.new("https://google.com").call
  end

  test "removes trailing slash" do
    assert_equal "http://google.com", UrlNormalizer.new("http://google.com/").call
  end

  test "returns nil if url is nil" do
    assert_nil UrlNormalizer.new(nil).call
  end

  test "returns nil if url is empty" do
    assert_nil UrlNormalizer.new(" ").call
  end

  test "normalizes url with special characters" do
    url = "https://uea.org/vikio/Kategorio:Novaĵoj_-_ILEI-KE"
    assert_equal url, UrlNormalizer.new(url).call
  end
end
