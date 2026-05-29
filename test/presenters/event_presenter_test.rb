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
end
