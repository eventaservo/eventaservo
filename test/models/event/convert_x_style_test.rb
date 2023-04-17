require "test_helper"

class Event::ConvertXStyleTest < ActiveSupport::TestCase
  def setup
    @text_with_x_chars = "Cxi tiu jxauxde, la gxentila knabo kun la cxapelo mangxis fresxan cxehxan kolbasanon"
    @converted_text = "Ĉi tiu ĵaŭde, la ĝentila knabo kun la ĉapelo manĝis freŝan ĉeĥan kolbasanon"
    @event = create(:event)
  end

  test "convert title when creating event" do
    event = create(:event, title: @text_with_x_chars)
    assert_equal @converted_text, event.title
  end

  test "do not convert title when updating" do
    @event.update(title: @text_with_x_chars)
    assert_equal @text_with_x_chars, @event.title
  end

  test "convert description when creating event" do
    event = create(:event, description: @text_with_x_chars)
    assert_equal @converted_text, event.description
  end

  test "do not convert description when updating" do
    @event.update(description: @text_with_x_chars)
    assert_equal @text_with_x_chars, @event.description
  end
end
