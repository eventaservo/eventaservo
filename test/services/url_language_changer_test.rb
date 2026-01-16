# frozen_string_literal: true

require "test_helper"

class UrlLanguageChangerTest < ActiveSupport::TestCase
  test "adds locale to URL without defined language and no paths" do
    url = "http://eventaservo.org"
    service = UrlLanguageChanger.new(url, "en")

    assert_equal "http://eventaservo.org/en", service.call
  end

  test "adds locale to URL without defined language with other paths" do
    url = "http://eventaservo.org/e/12345"
    service = UrlLanguageChanger.new(url, "en")

    assert_equal "http://eventaservo.org/en/e/12345", service.call
  end

  test "changes language when URL has defined language and no paths" do
    url = "http://eventaservo.org/eo"
    service = UrlLanguageChanger.new(url, "en")

    assert_equal "http://eventaservo.org/en", service.call
  end

  test "changes language when URL has defined language with other paths" do
    url = "http://eventaservo.org/eo/e/12345"
    service = UrlLanguageChanger.new(url, "en")

    assert_equal "http://eventaservo.org/en/e/12345", service.call
  end
end
