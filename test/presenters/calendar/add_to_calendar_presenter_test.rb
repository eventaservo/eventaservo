require "test_helper"

class Calendar::AddToCalendarPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "#url calls the url method for the provider class" do
    event = build_stubbed(:event)
    provider = :google
    presenter = Calendar::AddToCalendarPresenter.new(event: event, provider: provider)

    mock = Minitest::Mock.new
    mock.expect :url, "https://google.com"

    Calendar::Providers::Google.stub :new, ->(args) {
      assert_equal event, args[:event]
      mock
    } do
      assert_equal "https://google.com", presenter.url
    end
    mock.verify
  end

  test "#details returns the details for the event" do
    event = build_stubbed(:event)
    presenter = Calendar::AddToCalendarPresenter.new(event: event, provider: :google)

    assert_equal "#{event_url(code: event.code)}\n\n#{event.description}", presenter.details
  end

  test "#location returns the address when the event has address" do
    event = build_stubbed(:event)
    presenter = Calendar::AddToCalendarPresenter.new(event: event, provider: :google)

    assert_equal event.full_address, presenter.location
  end

  test "#location returns the event url when the event doesn't have address" do
    event = build_stubbed(:event, :online)
    presenter = Calendar::AddToCalendarPresenter.new(event: event, provider: :google)

    assert_equal event_url(code: event.code), presenter.location
  end
end
