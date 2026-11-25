# frozen_string_literal: true

require "test_helper"

class Events::AdminSearchQueryTest < ActiveSupport::TestCase
  setup do
    @valid_event = events(:valid_event)
    @meetup = events(:esperanto_meetup)
    @past_event = events(:past_event_danio_recent)
    @organization = organizations(:rotterdam_centre)
  end

  test "returns active events ordered by date_start descending by default" do
    @meetup.update_column(:deleted, true)

    result = Events::AdminSearchQuery.new.call

    assert_includes result, @valid_event
    assert_not_includes result, @meetup
    assert_equal result.map(&:date_start).sort.reverse, result.map(&:date_start)
  end

  test "returns only soft-deleted events when forigitaj is 1" do
    @meetup.update_column(:deleted, true)

    result = Events::AdminSearchQuery.new(forigitaj: "1").call

    assert_includes result, @meetup
    assert_not_includes result, @valid_event
  end

  test "filters by start_date and end_date" do
    result = Events::AdminSearchQuery.new(
      start_date: 1.week.from_now.to_date.to_s,
      end_date: 3.weeks.from_now.to_date.to_s
    ).call

    assert_includes result, @meetup
    assert_not_includes result, @valid_event
    assert_not_includes result, @past_event
  end

  test "filters by title case-insensitively and escapes LIKE metacharacters" do
    result = Events::AdminSearchQuery.new(title: "rails conference").call
    assert_includes result, @valid_event
    assert_not_includes result, @meetup

    escaped_result = Events::AdminSearchQuery.new(title: "Rails%Conference").call
    assert_not_includes escaped_result, @valid_event
  end

  test "filters by country_id" do
    result = Events::AdminSearchQuery.new(country_id: @past_event.country_id).call

    assert_includes result, @past_event
    assert_not_includes result, @valid_event
  end

  test "filters by organization_id" do
    @valid_event.organizations << @organization

    result = Events::AdminSearchQuery.new(organization_id: @organization.id).call

    assert_includes result, @valid_event
    assert_not_includes result, @meetup
  end

  test "filters events without location when senlokaj is 1" do
    @past_event.update_columns(latitude: nil, longitude: nil, online: false)

    result = Events::AdminSearchQuery.new(senlokaj: "1").call

    assert_includes result, @past_event
    assert_not_includes result, @valid_event
  end

  test "combines multiple filters" do
    @valid_event.organizations << @organization

    result = Events::AdminSearchQuery.new(
      title: "Rails",
      country_id: @valid_event.country_id,
      organization_id: @organization.id
    ).call

    assert_equal [@valid_event], result.to_a
  end
end
