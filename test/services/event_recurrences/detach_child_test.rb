# frozen_string_literal: true

require "test_helper"

class EventRecurrences::DetachChildTest < ActiveSupport::TestCase
  test "detaches a child event from its series" do
    master = events(:valid_event)
    child = Event.create!(
      title: master.title,
      description: master.description,
      city: master.city,
      country: master.country,
      user: master.user,
      date_start: 2.months.from_now,
      date_end: 2.months.from_now + 3.days,
      code: "detach01",
      site: master.site,
      recurrent_master_event_id: master.id
    )

    result = EventRecurrences::DetachChild.call(event: child)

    assert result.success?
    assert child.reload.detached_from_recurrent_series?
  end

  test "fails when event is not a child" do
    event = events(:esperanto_meetup)

    result = EventRecurrences::DetachChild.call(event:)

    assert result.failure?
    assert_equal "Event is not a recurring child", result.error
  end

  test "fails when already detached" do
    master = events(:valid_event)
    child = Event.create!(
      title: master.title,
      description: master.description,
      city: master.city,
      country: master.country,
      user: master.user,
      date_start: 2.months.from_now,
      date_end: 2.months.from_now + 3.days,
      code: "detach02",
      site: master.site,
      recurrent_master_event_id: master.id,
      metadata: {"detached_from_recurrent_series" => true}
    )

    result = EventRecurrences::DetachChild.call(event: child)

    assert result.failure?
    assert_equal "Event is already detached", result.error
  end
end
