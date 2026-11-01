# frozen_string_literal: true

require "test_helper"

# Unit tests for UrlLanguageChanger service.
class UrlLanguageChanger::CallTest < ActiveSupport::TestCase
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

  test "removes locale prefix and adds locale query param when switching to default locale (eo) from root" do
    url = "http://eventaservo.org/en"
    service = UrlLanguageChanger.new(url, "eo")

    assert_equal "http://eventaservo.org/?locale=eo", service.call
  end

  test "removes locale prefix and adds locale query param when switching to default locale (eo) with other paths" do
    url = "http://eventaservo.org/en/e/12345"
    service = UrlLanguageChanger.new(url, "eo")

    assert_equal "http://eventaservo.org/e/12345?locale=eo", service.call
  end

  test "preserves existing query parameters when switching to default locale" do
    url = "http://eventaservo.org/en/e/12345?tab=past"
    service = UrlLanguageChanger.new(url, "eo")

    assert_equal "http://eventaservo.org/e/12345?locale=eo&tab=past", service.call
  end

  test "strips locale query parameter when switching to non-default locale" do
    url = "http://eventaservo.org/e/12345?locale=eo&tab=past"
    service = UrlLanguageChanger.new(url, "pt_BR")

    assert_equal "http://eventaservo.org/pt_BR/e/12345?tab=past", service.call
  end
end
