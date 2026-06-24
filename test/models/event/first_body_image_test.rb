# frozen_string_literal: true

require "test_helper"

class Event::FirstBodyImageTest < ActiveSupport::TestCase
  test "first_body_image returns the first image attachment from body" do
    event = events(:valid_event)

    # Mock an ActionText::Attachment with an image attachable
    image_attachable = Object.new
    def image_attachable.content_type
      "image/png"
    end

    image_attachment = Object.new
    def image_attachment.attachable
      @attachable
    end
    image_attachment.define_singleton_method(:attachable=) { |val| @attachable = val }
    image_attachment.attachable = image_attachable

    # Mock a non-image attachment (should be skipped)
    text_attachable = Object.new
    def text_attachable.content_type
      "text/plain"
    end

    text_attachment = Object.new
    def text_attachment.attachable
      @attachable
    end
    text_attachment.define_singleton_method(:attachable=) { |val| @attachable = val }
    text_attachment.attachable = text_attachable

    # Mock body (the ActionText::Content) that holds attachments
    body_mock = Object.new
    def body_mock.attachments
      @attachments
    end
    body_mock.define_singleton_method(:attachments=) { |val| @attachments = val }
    body_mock.attachments = [text_attachment, image_attachment]

    # Mock enhavo (the rich text record) which returns body
    enhavo_mock = Object.new
    def enhavo_mock.body
      @body
    end
    enhavo_mock.define_singleton_method(:body=) { |val| @body = val }
    enhavo_mock.body = body_mock

    event.stub :enhavo, enhavo_mock do
      result = event.send(:first_body_image)
      assert_equal image_attachment, result
    end
  end

  test "first_body_image returns nil when body is nil" do
    event = events(:valid_event)

    enhavo_mock = Object.new
    def enhavo_mock.body
      nil
    end

    event.stub :enhavo, enhavo_mock do
      assert_nil event.send(:first_body_image)
    end
  end

  test "first_body_image returns nil when attachments is nil" do
    event = events(:valid_event)

    body_mock = Object.new
    def body_mock.attachments
      nil
    end

    enhavo_mock = Object.new
    def enhavo_mock.body
      @body
    end
    enhavo_mock.define_singleton_method(:body=) { |val| @body = val }
    enhavo_mock.body = body_mock

    event.stub :enhavo, enhavo_mock do
      assert_nil event.send(:first_body_image)
    end
  end

  test "first_body_image returns nil when no image attachments" do
    event = events(:valid_event)

    text_attachable = Object.new
    def text_attachable.content_type
      "application/pdf"
    end

    text_attachment = Object.new
    def text_attachment.attachable
      @attachable
    end
    text_attachment.define_singleton_method(:attachable=) { |val| @attachable = val }
    text_attachment.attachable = text_attachable

    body_mock = Object.new
    def body_mock.attachments
      @attachments
    end
    body_mock.define_singleton_method(:attachments=) { |val| @attachments = val }
    body_mock.attachments = [text_attachment]

    enhavo_mock = Object.new
    def enhavo_mock.body
      @body
    end
    enhavo_mock.define_singleton_method(:body=) { |val| @body = val }
    enhavo_mock.body = body_mock

    event.stub :enhavo, enhavo_mock do
      assert_nil event.send(:first_body_image)
    end
  end

  test "first_body_image returns nil when attachable is nil" do
    event = events(:valid_event)

    attachment = Object.new
    def attachment.attachable
      nil
    end

    body_mock = Object.new
    def body_mock.attachments
      @attachments
    end
    body_mock.define_singleton_method(:attachments=) { |val| @attachments = val }
    body_mock.attachments = [attachment]

    enhavo_mock = Object.new
    def enhavo_mock.body
      @body
    end
    enhavo_mock.define_singleton_method(:body=) { |val| @body = val }
    enhavo_mock.body = body_mock

    event.stub :enhavo, enhavo_mock do
      assert_nil event.send(:first_body_image)
    end
  end
end
