# frozen_string_literal: true

require "test_helper"

class Event::WithoutLocationScopeTest < ActiveSupport::TestCase
  test "includes events with nil latitude and online false" do
    event = events(:valid_event)
    event.update_columns(latitude: nil, longitude: nil, online: false)

    assert_includes Event.without_location, event
  end

  test "excludes online events even if latitude is nil" do
    event = events(:valid_event)
    event.update_columns(latitude: nil, longitude: nil, online: true)

    assert_not_includes Event.without_location, event
  end

  test "excludes events with latitude set" do
    event = events(:valid_event)
    event.update_columns(latitude: 40.7128, online: false)

    assert_not_includes Event.without_location, event
  end
end
