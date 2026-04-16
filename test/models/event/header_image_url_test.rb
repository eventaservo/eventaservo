# frozen_string_literal: true

require "test_helper"

class Event::HeaderImageUrlTest < ActiveSupport::TestCase
  test "header_image_url should return a proxied storage URL" do
    event = events(:valid_event)

    variant_mock = Minitest::Mock.new
    variant_mock.expect :processed, variant_mock

    image_mock = Object.new
    def image_mock.is_a?(klass)
      false
    end
    image_mock.define_singleton_method(:variant) { |args| variant_mock }

    # Stub the actual helper that was previously missing
    expected_url = "https://eventaservo.org/rails/active_storage/blobs/proxy/abc"

    Rails.application.routes.url_helpers.stub :rails_storage_proxy_url, expected_url do
      event.stub :header_image, image_mock do
        result = event.header_image_url
        assert_equal expected_url, result
      end
    end

    variant_mock.verify
  end

  test "header_image_url should return original URL if ActionText::Attachment" do
    event = events(:valid_event)

    attachment_mock = Minitest::Mock.new
    attachment_mock.expect :is_a?, true, [ActionText::Attachment]
    attachment_mock.expect :url, "https://example.com/original.jpg"

    event.stub :header_image, attachment_mock do
      result = event.header_image_url
      assert_equal "https://example.com/original.jpg", result
    end

    attachment_mock.verify
  end
end
