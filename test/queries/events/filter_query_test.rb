# frozen_string_literal: true

require "test_helper"

class Events::FilterQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @country_id = 1
  end

  # -- Base scope passthrough --

  test "applies filters on top of provided scope without altering temporal boundary" do
    past_event = create_event(
      title: "Past Event",
      date_start: 2.months.ago,
      date_end: 2.months.ago + 2.hours
    )

    result_all = Events::FilterQuery.new(scope: Event.all).call
    result_venontaj = Events::FilterQuery.new(scope: Event.venontaj).call

    assert_includes result_all, past_event
    assert_not_includes result_venontaj, past_event
  end

  # -- Organization filter --

  test "filters by organization short_name" do
    org = Organization.create!(name: "Test Org", short_name: "testorg", country_id: @country_id)
    matching_event = create_event(title: "Org Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    other_event = create_event(title: "Other Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    matching_event.organizations << org

    result = Events::FilterQuery.new(scope: Event.all, organization: "testorg").call

    assert_includes result, matching_event
    assert_not_includes result, other_event
  end

  test "ignores organization filter when nil" do
    event = create_event(title: "Any Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)

    result = Events::FilterQuery.new(scope: Event.all, organization: nil).call

    assert_includes result, event
  end

  # -- Tag filter --

  test "filters by tag IDs" do
    tag = tags(:kurso)
    tagged_event = create_event(title: "Kurso Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    untagged_event = create_event(title: "Plain Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    tagged_event.tags << tag

    result = Events::FilterQuery.new(scope: Event.all, tag_ids: [tag.id]).call

    assert_includes result, tagged_event
    assert_not_includes result, untagged_event
  end

  test "ignores tag filter when empty" do
    event = create_event(title: "Any Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)

    result = Events::FilterQuery.new(scope: Event.all, tag_ids: []).call

    assert_includes result, event
  end

  # -- Duration type filter --

  # NOTE: The unutagaj/plurtagaj scopes currently look for group_name "characteristic"
  # but the after_save callback tags events with group_name "time". This is a
  # pre-existing mismatch — these tests verify FilterQuery delegates correctly,
  # even though the underlying scopes may not match any events.
  test "delegates unutaga filter to the unutagaj scope" do
    create_event(title: "One Day", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)

    result = Events::FilterQuery.new(scope: Event.all, duration_type: "unutaga").call

    assert_equal Event.all.unutagaj.to_a, result.to_a
  end

  test "delegates plurtaga filter to the plurtagaj scope" do
    create_event(title: "Multi Day", date_start: 1.week.from_now, date_end: 1.week.from_now + 3.days)

    result = Events::FilterQuery.new(scope: Event.all, duration_type: "plurtaga").call

    assert_equal Event.all.plurtagaj.to_a, result.to_a
  end

  test "ignores duration type filter when nil" do
    event = create_event(title: "Any Event", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)

    result = Events::FilterQuery.new(scope: Event.all, duration_type: nil).call

    assert_includes result, event
  end

  # -- Combined filters --

  test "combines multiple filters" do
    tag = tags(:kurso)
    org = Organization.create!(name: "Combo Org", short_name: "comborg", country_id: @country_id)

    matching_event = create_event(title: "Match", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    matching_event.tags << tag
    matching_event.organizations << org

    only_tag_event = create_event(title: "Tag Only", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    only_tag_event.tags << tag

    only_org_event = create_event(title: "Org Only", date_start: 1.week.from_now, date_end: 1.week.from_now + 2.hours)
    only_org_event.organizations << org

    result = Events::FilterQuery.new(
      scope: Event.all,
      organization: "comborg",
      tag_ids: [tag.id]
    ).call

    assert_includes result, matching_event
    assert_not_includes result, only_tag_event
    assert_not_includes result, only_org_event
  end

  private

  # @param title [String]
  # @param date_start [Time]
  # @param date_end [Time]
  # @return [Event]
  def create_event(title:, date_start:, date_end:, **attrs)
    Event.create!(
      title: title,
      description: "Test event",
      city: "Test City",
      country_id: @country_id,
      date_start: date_start,
      date_end: date_end,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://test.example.com",
      user: @user,
      **attrs
    )
  end
end
