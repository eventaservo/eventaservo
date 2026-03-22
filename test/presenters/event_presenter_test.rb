require "test_helper"

class EventPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "#add_to_calendar_links has keys for the providers" do
    event = build_stubbed(:event)
    presenter = EventPresenter.new(event: event)
    links = presenter.add_to_calendar_links

    assert_includes links.keys, :ics
    assert_includes links.keys, :google
    assert_includes links.keys, :apple
    assert_includes links.keys, :outlook
    assert_includes links.keys, :yahoo
  end

  # -- #recurrence_type_badge_html --

  test "#recurrence_type_badge_html returns Master badge when event has no master" do
    event = build_stubbed(:event, recurrent_master_event_id: nil)
    html = presenter(event).recurrence_type_badge_html

    assert_includes html, "Master"
    assert_includes html, "badge bg-primary"
  end

  test "#recurrence_type_badge_html returns Child badge when event has a master" do
    event = build_stubbed(:event, recurrent_master_event_id: 999)
    html = presenter(event).recurrence_type_badge_html

    assert_includes html, "Child"
    assert_includes html, "badge bg-light text-dark"
  end

  # -- #recurrence_status_badge_html --

  test "#recurrence_status_badge_html returns Detached badge for detached event" do
    event = build_stubbed(:event, metadata: {"detached_from_recurrent_series" => true})
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Detached"
    assert_includes html, "badge bg-warning text-dark"
  end

  test "#recurrence_status_badge_html returns Cancelled badge for cancelled event" do
    event = build_stubbed(:event, cancelled: true)
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Cancelled"
    assert_includes html, "badge bg-danger"
  end

  test "#recurrence_status_badge_html returns Deleted badge for deleted event" do
    event = build_stubbed(:event, deleted: true)
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Deleted"
    assert_includes html, "badge bg-dark"
  end

  test "#recurrence_status_badge_html returns Past badge for past event" do
    event = build_stubbed(:event, :past)
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Past"
    assert_includes html, "badge bg-secondary"
  end

  test "#recurrence_status_badge_html returns Upcoming badge for future event" do
    event = build_stubbed(:event, :future)
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Upcoming"
    assert_includes html, "badge bg-success"
  end

  test "#recurrence_status_badge_html prioritizes detached over cancelled" do
    event = build_stubbed(:event, cancelled: true, metadata: {"detached_from_recurrent_series" => true})
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Detached"
  end

  test "#recurrence_status_badge_html prioritizes cancelled over deleted" do
    event = build_stubbed(:event, cancelled: true, deleted: true)
    html = presenter(event).recurrence_status_badge_html

    assert_includes html, "Cancelled"
  end

  private

  # @param event [Event]
  # @return [EventPresenter]
  def presenter(event)
    EventPresenter.new(event:)
  end
end
