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

  private

  # @param event [Event]
  # @return [EventPresenter]
  def presenter(event)
    EventPresenter.new(event:)
  end
end
