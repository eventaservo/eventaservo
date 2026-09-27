# frozen_string_literal: true

require "test_helper"

class OrganizationsHelperTest < ActionView::TestCase
  include OrganizationsHelper

  test "display_event_tags returns correct bootstrap 5 classes" do
    event = create(:event)

    category_tag = Tag.find_or_create_by!(name: "Kategorio", group_name: "category")
    characteristic_tag = Tag.find_or_create_by!(name: "Karakterizo", group_name: "characteristic")

    event.tags = [category_tag, characteristic_tag]

    result = display_event_tags(event)

    assert_match(/text-bg-info/, result)
    assert_match(/text-bg-warning/, result)
    assert_match(/badge rounded-pill/, result)
  end

  test "display_event_tags ignores and excludes time duration tags" do
    event = create(:event)

    category_tag = Tag.find_or_create_by!(name: "Kategorio", group_name: "category")
    time_tag = Tag.find_or_create_by!(name: "Unutaga", group_name: "time")

    event.tags = [category_tag, time_tag]

    result = display_event_tags(event)

    assert_match(/Kategorio/, result)
    refute_match(/Unutaga/, result)
  end

  test "display_event_days_left returns correct text" do
    event = create(:event, date_start: Time.zone.now, date_end: 1.day.from_now)
    assert_equal "| finiĝos morgaŭ", display_event_days_left(event)

    event = create(:event, date_start: Time.zone.now, date_end: 2.days.from_now)
    assert_equal "| finiĝos post 2 tagoj", display_event_days_left(event)

    event = create(:event, date_start: 2.days.ago, date_end: 1.day.ago)
    assert_equal "", display_event_days_left(event)
  end

  test "display_organizations_for_event lists all organizations when not limited" do
    event = create(:event)
    event.organizations = [organizations(:rotterdam_centre), organizations(:sat)]

    result = display_organizations_for_event(event)

    assert_match organizations(:rotterdam_centre).short_name, result
    assert_match organizations(:sat).short_name, result
  end

  test "display_organizations_for_event limits to first organization plus counter when limited" do
    event = create(:event)
    event.organizations = [organizations(:rotterdam_centre), organizations(:sat)]

    result = display_organizations_for_event(event, limited: true)

    assert_match organizations(:rotterdam_centre).short_name, result
    assert_match(/\+1/, result)
    assert_no_match organizations(:sat).short_name, result
  end

  test "display_organizations_for_event shows the single organization when limited and only one exists" do
    event = create(:event)
    event.organizations = [organizations(:rotterdam_centre)]

    result = display_organizations_for_event(event, limited: true)

    assert_match organizations(:rotterdam_centre).short_name, result
    assert_no_match(/\+0/, result)
  end

  test "display_organizations_for_event does not query organizations when they are preloaded" do
    event = create(:event)
    event.organizations = [organizations(:rotterdam_centre), organizations(:sat)]
    event = Event.includes(:organizations).find(event.id)

    assert event.organizations.loaded?
    assert_no_queries_match(/FROM "organizations"/) do
      display_organizations_for_event(event, limited: true)
    end
  end
end
