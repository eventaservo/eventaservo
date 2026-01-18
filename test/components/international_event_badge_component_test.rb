# frozen_string_literal: true

require "test_helper"

class InternationalEventBadgeComponentTest < ViewComponent::TestCase
  test "renders the badge if the event is international" do
    event = create(:event, :international_calendar)
    render_inline(InternationalEventBadgeComponent.new(event: event))
    assert_selector ".badge-success", text: /Internacia Evento/
  end

  test "does not render the badge if the event is not international" do
    event = create(:event, international_calendar: false)
    render_inline(InternationalEventBadgeComponent.new(event: event))
    refute_selector ".badge-success", text: /Internacia Evento/
  end
end
