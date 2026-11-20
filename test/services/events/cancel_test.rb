# frozen_string_literal: true

require "test_helper"

class Events::CancelTest < ActiveSupport::TestCase
  test "cancels event with reason when user is owner" do
    event = events(:valid_event)
    user = users(:user)

    assert_difference "Log.count", 1 do
      result = Events::Cancel.call(event:, user:, cancel_reason: "Weather")
      assert result.success?
    end

    event.reload
    assert event.cancelled?
    assert_equal "Weather", event.cancel_reason
  end

  test "cancels event when user is member of event organization" do
    event = events(:valid_event)
    event.organizations << organizations(:rotterdam_centre)
    member = users(:speaker)

    result = Events::Cancel.call(event:, user: member, cancel_reason: "Venue issue")

    assert result.success?
    assert event.reload.cancelled?
  end

  test "cancels event when user is admin" do
    event = events(:valid_event)
    admin = users(:admin_user)

    result = Events::Cancel.call(event:, user: admin)

    assert result.success?
    assert event.reload.cancelled?
  end

  test "fails when user is not authorized" do
    event = events(:valid_event)
    other_user = users(:speaker)

    result = Events::Cancel.call(event:, user: other_user, cancel_reason: "Unauthorized")

    assert result.failure?
    assert_not event.reload.cancelled?
  end
end
