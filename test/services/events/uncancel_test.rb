# frozen_string_literal: true

require "test_helper"

class Events::UncancelTest < ActiveSupport::TestCase
  test "uncancels event and clears cancel_reason when user is owner" do
    event = events(:valid_event)
    event.update!(cancelled: true, cancel_reason: "Weather")
    user = users(:user)

    assert_difference "Log.count", 1 do
      result = Events::Uncancel.call(event:, user:)
      assert result.success?
    end

    event.reload
    assert_not event.cancelled?
    assert_nil event.cancel_reason
  end

  test "fails when user is not authorized" do
    event = events(:valid_event)
    event.update!(cancelled: true, cancel_reason: "Weather")
    other_user = users(:speaker)

    result = Events::Uncancel.call(event:, user: other_user)

    assert result.failure?
    assert event.reload.cancelled?
    assert_equal "Weather", event.cancel_reason
  end
end
