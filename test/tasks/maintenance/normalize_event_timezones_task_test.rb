# frozen_string_literal: true

require "test_helper"

module Maintenance
  class NormalizeEventTimezonesTaskTest < ActiveSupport::TestCase
    def setup
      @user = users(:user)
      @country_id = 1
      @event_attrs = {
        title: "Test Event",
        description: "Test description",
        city: "Test City",
        date_start: Time.zone.now,
        date_end: Time.zone.now + 1.hour,
        code: "tz-test-#{SecureRandom.hex(4)}",
        site: "https://example.com",
        country_id: @country_id,
        user: @user
      }
    end

    test "normalizes legacy America/Buenos_Aires to canonical form" do
      event = Event.create!(**@event_attrs)
      event.update_column(:time_zone, "America/Buenos_Aires")
      event.reload

      Maintenance::NormalizeEventTimezonesTask.process(event)
      event.reload

      assert_equal "America/Argentina/Buenos_Aires", event.time_zone
    end

    test "normalizes legacy Asia/Calcutta to canonical form" do
      event = Event.create!(**@event_attrs)
      event.update_column(:time_zone, "Asia/Calcutta")
      event.reload

      Maintenance::NormalizeEventTimezonesTask.process(event)
      event.reload

      assert_equal "Asia/Kolkata", event.time_zone
    end

    test "does not modify already canonical timezone" do
      event = Event.create!(**@event_attrs)
      event.update_column(:time_zone, "Europe/Berlin")
      event.reload

      Maintenance::NormalizeEventTimezonesTask.process(event)
      event.reload

      assert_equal "Europe/Berlin", event.time_zone
    end

    test "normalizes blank timezone to Etc/UTC" do
      event = Event.create!(**@event_attrs)
      event.update_column(:time_zone, "")
      event.reload

      Maintenance::NormalizeEventTimezonesTask.process(event)
      event.reload

      assert_equal "Etc/UTC", event.time_zone
    end

    test "preserves original timezone when normalization fails" do
      event = Event.create!(**@event_attrs)
      event.update_column(:time_zone, "Some/Unknown_Zone")
      event.reload

      Maintenance::NormalizeEventTimezonesTask.process(event)
      event.reload

      assert_equal "Some/Unknown_Zone", event.time_zone
    end

    test "collection returns all events" do
      collection = Maintenance::NormalizeEventTimezonesTask.collection

      assert_kind_of ActiveRecord::Relation, collection
      assert_equal Event.unscoped.count, collection.count
    end
  end
end
