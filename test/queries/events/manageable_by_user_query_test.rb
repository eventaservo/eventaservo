# frozen_string_literal: true

require "test_helper"

class Events::ManageableByUserQueryTest < ActiveSupport::TestCase
  test "returns events owned by the user" do
    user = users(:user)
    event = events(:valid_event)

    result = Events::ManageableByUserQuery.new(user:).call

    assert_includes result, event
  end

  test "returns events linked to organizations the user belongs to" do
    member = users(:speaker)
    event = events(:valid_event)
    event.organizations << organizations(:rotterdam_centre)

    result = Events::ManageableByUserQuery.new(user: member).call

    assert_includes result, event
  end

  test "does not return events owned by other users without shared organization" do
    other_user = users(:speaker)
    event = events(:valid_event)

    result = Events::ManageableByUserQuery.new(user: other_user).call

    assert_not_includes result, event
  end

  test "returns all non-deleted events including personal events for administrators" do
    admin = users(:admin_user)
    personal_event = events(:valid_event)

    result = Events::ManageableByUserQuery.new(user: admin).call

    assert_includes result, personal_event
  end

  test "filters by upcoming and past status" do
    user = users(:user)
    upcoming_event = events(:valid_event)
    past_event = events(:valid_event).dup
    past_event.assign_attributes(
      title: "Past Esperanto Gathering",
      code: "past123",
      date_start: 2.months.ago,
      date_end: 2.months.ago + 1.day
    )
    past_event.save!

    upcoming = Events::ManageableByUserQuery.new(user:, status: "upcoming").call
    past = Events::ManageableByUserQuery.new(user:, status: "past").call

    assert_includes upcoming, upcoming_event
    assert_not_includes upcoming, past_event
    assert_includes past, past_event
    assert_not_includes past, upcoming_event
  end
end
