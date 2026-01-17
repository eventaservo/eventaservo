# frozen_string_literal: true

require "test_helper"

class ToolsTest < ActiveSupport::TestCase
  test "convert_X_characters should convert X characters to their corresponding Esperanto characters" do
    text = "Cxi tiu jxauxde, la gxentila knabo kun la cxapelo mangxis fresxan cxehxan kolbasanon"
    expected = "Ĉi tiu ĵaŭde, la ĝentila knabo kun la ĉapelo manĝis freŝan ĉeĥan kolbasanon"
    assert_equal expected, Tools.convert_X_characters(text)
  end
end
