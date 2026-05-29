# frozen_string_literal: true

require "test_helper"

class Event::HeaderImageUrlTest < ActiveSupport::TestCase
  test "header_image_url should return a proxied representation URL via .url" do
    event = events(:valid_event)

    expected_url = "https://eventaservo.org/rails/active_storage/representations/proxy/abc/123"

    variant_mock = Minitest::Mock.new
    variant_mock.expect :processed, variant_mock
    variant_mock.expect :url, expected_url

    # Use Object.new to allow multiple calls without strict Minitest::Mock ordering/count
    image_mock = Object.new
    def image_mock.is_a?(_klass)
      false
    end
    image_mock.define_singleton_method(:variant) do |args|
      @variant_args = args
      variant_mock
    end
    def image_mock.variant_args
      @variant_args
    end

    event.stub :header_image, image_mock do
      result = event.header_image_url
      assert_equal expected_url, result
    end

    variant_mock.verify
    assert_equal({resize_to_limit: [400, 400]}, image_mock.variant_args)
  end

  test "header_image_url should return original URL if ActionText::Attachment" do
    event = events(:valid_event)

    attachment_mock = Object.new
    def attachment_mock.is_a?(klass)
      klass == ActionText::Attachment
    end

    def attachment_mock.url
      "https://example.com/original.jpg"
    end

    event.stub :header_image, attachment_mock do
      result = event.header_image_url
      assert_equal "https://example.com/original.jpg", result
    end
  end
end
