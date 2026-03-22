# frozen_string_literal: true

require "test_helper"

class EventRecurrence::ValidationTest < ActiveSupport::TestCase
  test "valid weekly recurrence" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "weekly",
      interval: 1,
      days_of_week: [2, 4],
      end_type: "never"
    )
    assert recurrence.valid?, recurrence.errors.full_messages.join(", ")
  end

  test "valid monthly recurrence with fixed day" do
    recurrence = EventRecurrence.new(
      master_event: events(:esperanto_meetup),
      frequency: "monthly",
      interval: 1,
      day_of_month: 15,
      end_type: "never"
    )
    assert recurrence.valid?, recurrence.errors.full_messages.join(", ")
  end

  test "valid monthly recurrence with nth weekday" do
    recurrence = EventRecurrence.new(
      master_event: events(:esperanto_meetup),
      frequency: "monthly",
      interval: 1,
      week_of_month: 1,
      day_of_week_monthly: 6,
      end_type: "never"
    )
    assert recurrence.valid?, recurrence.errors.full_messages.join(", ")
  end

  test "valid yearly recurrence" do
    recurrence = EventRecurrence.new(
      master_event: events(:esperanto_meetup),
      frequency: "yearly",
      interval: 1,
      month_of_year: 7,
      day_of_month: 17,
      end_type: "never"
    )
    assert recurrence.valid?, recurrence.errors.full_messages.join(", ")
  end

  test "requires frequency" do
    recurrence = EventRecurrence.new(master_event: events(:valid_event), end_type: "never")
    assert_not recurrence.valid?
    assert recurrence.errors[:frequency].any?
  end

  test "requires interval greater than 0" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "daily",
      interval: 0,
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:interval].any?
  end

  test "requires end_date when end_type is on_date" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "daily",
      interval: 1,
      end_type: "on_date"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:end_date].any?
  end

  test "end_date must be in the future" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "daily",
      interval: 1,
      end_type: "on_date",
      end_date: 1.day.ago.to_date
    )
    assert_not recurrence.valid?
    assert_includes recurrence.errors[:end_date], "must be in the future"
  end

  test "requires days_of_week for weekly frequency" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "weekly",
      interval: 1,
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:days_of_week].any?
  end

  test "days_of_week must be valid values 0-6" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "weekly",
      interval: 1,
      days_of_week: [0, 7],
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:days_of_week].any?
  end

  test "monthly requires either day_of_month or week_of_month pattern" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "monthly",
      interval: 1,
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:base].any?
  end

  test "monthly cannot have both day_of_month and week_of_month" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "monthly",
      interval: 1,
      day_of_month: 15,
      week_of_month: 1,
      day_of_week_monthly: 6,
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:base].any?
  end

  test "yearly requires month_of_year" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "yearly",
      interval: 1,
      day_of_month: 17,
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:month_of_year].any?
  end

  test "yearly requires day_of_month" do
    recurrence = EventRecurrence.new(
      master_event: events(:valid_event),
      frequency: "yearly",
      interval: 1,
      month_of_year: 7,
      end_type: "never"
    )
    assert_not recurrence.valid?
    assert recurrence.errors[:day_of_month].any?
  end
end
