# frozen_string_literal: true

require "test_helper"
require "view_component/test_helpers"

class Events::CardComponentTest < ActionView::TestCase
  include ViewComponent::TestHelpers

  test "renders a link to the event and its description" do
    event = events(:valid_event)

    render_inline(Events::CardComponent.new(event:))

    assert_selector "a[href='/e/rails2024']", text: "Rails Conference 2024"
    assert_text "Annual Rails conference for developers"
  end
end
