require "test_helper"

class ToolsTest < ActiveJob::TestCase
  test ".convert_X_characters" do
    original_text =
      "Cxi tiu jxauxde, la gxentila knabo kun la cxapelo mangxis fresxan cxehxan kolbasanon kaj trinkis fresxan teon el cxina taso."

    converterd_text =
      "Ĉi tiu ĵaŭde, la ĝentila knabo kun la ĉapelo manĝis freŝan ĉeĥan kolbasanon kaj trinkis freŝan teon el ĉina taso."

    assert_equal converterd_text, Tools.convert_X_characters(original_text)
  end
end
