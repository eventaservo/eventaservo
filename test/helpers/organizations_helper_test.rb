# frozen_string_literal: true

require "test_helper"

class OrganizationsHelperTest < ActionView::TestCase
  include OrganizationsHelper

  test "display_event_tags returns correct bootstrap 5 classes" do
    event = create(:event)

    category_tag = Tag.find_or_create_by!(name: "Kategorio", group_name: "category")
    characteristic_tag = Tag.find_or_create_by!(name: "Karakterizo", group_name: "characteristic")

    event.tags << category_tag
    event.tags << characteristic_tag

    result = display_event_tags(event)

    assert_match(/text-bg-info/, result)
    assert_match(/text-bg-warning/, result)
    assert_match(/badge rounded-pill/, result)
  end

  test "display_event_days_left returns correct text" do
    event = create(:event, date_start: Time.zone.now, date_end: 1.day.from_now)
    assert_equal "| finiĝos morgaŭ", display_event_days_left(event)

    event = create(:event, date_start: Time.zone.now, date_end: 2.days.from_now)
    assert_equal "| finiĝos post 2 tagoj", display_event_days_left(event)

    event = create(:event, date_start: 2.days.ago, date_end: 1.day.ago)
    assert_equal "", display_event_days_left(event)
  end
end
