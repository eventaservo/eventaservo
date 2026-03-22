# frozen_string_literal: true

require "test_helper"

class Event::RecurringEventsTest < ActiveSupport::TestCase
  test "standalone event is not part of a series" do
    event = events(:esperanto_meetup)
    assert_not event.recurring_master?
    assert_not event.recurring_child?
    assert_not event.part_of_series?
  end

  test "event with recurrence is a recurring master" do
    event = events(:valid_event)
    # The fixture creates a recurrence for valid_event
    assert event.recurring_master?
    assert_not event.recurring_child?
    assert event.part_of_series?
  end

  test "child event is a recurring child" do
    master = events(:valid_event)
    child = Event.create!(
      title: master.title,
      description: master.description,
      city: master.city,
      country: master.country,
      user: master.user,
      date_start: 2.months.from_now,
      date_end: 2.months.from_now + 3.days,
      code: "child001",
      site: master.site,
      recurrent_master_event_id: master.id
    )

    assert child.recurring_child?
    assert_not child.recurring_master?
    assert child.part_of_series?
    assert_equal master, child.recurrent_master_event
  end

  test "detach_from_recurrent_series sets metadata flag" do
    master = events(:valid_event)
    child = Event.create!(
      title: master.title,
      description: master.description,
      city: master.city,
      country: master.country,
      user: master.user,
      date_start: 2.months.from_now,
      date_end: 2.months.from_now + 3.days,
      code: "child002",
      site: master.site,
      recurrent_master_event_id: master.id
    )

    assert_not child.detached_from_recurrent_series?
    child.detach_from_recurrent_series!
    assert child.reload.detached_from_recurrent_series?
    # Still linked to master
    assert_equal master.id, child.recurrent_master_event_id
  end

  test "root_event returns master for child" do
    master = events(:valid_event)
    child = Event.create!(
      title: master.title,
      description: master.description,
      city: master.city,
      country: master.country,
      user: master.user,
      date_start: 2.months.from_now,
      date_end: 2.months.from_now + 3.days,
      code: "child003",
      site: master.site,
      recurrent_master_event_id: master.id
    )

    assert_equal master, child.root_event
    assert_equal master, master.root_event
  end

  test "recurring_masters scope returns events with recurrence" do
    masters = Event.recurring_masters
    assert_includes masters, events(:valid_event)
    assert_not_includes masters, events(:esperanto_meetup)
  end
end
