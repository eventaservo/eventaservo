# frozen_string_literal: true

require "test_helper"

class EventsController::UncancelTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:user)
    @admin = users(:admin_user)
    @other_user = users(:teacher)
    @event = events(:valid_event)
    @event.update!(cancelled: true, cancel_reason: "Weather conditions")
  end

  # Success cases

  test "uncancels the event, clears reason, creates audit log, and tracks with ahoy" do
    sign_in @owner

    assert_difference ["Log.count", "Ahoy::Event.count"], 1 do
      post event_uncancel_path(event_code: @event.code)
    end

    assert_redirected_to event_path(code: @event.code)
    assert_equal I18n.t("flash.events.uncancelled"), flash[:notice]

    @event.reload
    assert_not @event.cancelled?
    assert_nil @event.cancel_reason

    log = Log.last
    assert_equal "Event uncancelled", log.text
    assert_equal @owner, log.user
    assert_equal @event, log.loggable
  end

  test "uncancels the event using short_url" do
    sign_in @owner
    @event.update!(short_url: "rails-conf-2024")

    post event_uncancel_path(event_code: @event.short_url)

    assert_redirected_to event_path(code: @event.short_url)
    @event.reload
    assert_not @event.cancelled?
    assert_nil @event.cancel_reason
  end

  test "allows an admin to uncancel the event" do
    sign_in @admin

    assert_difference "Log.count", 1 do
      post event_uncancel_path(event_code: @event.code)
    end

    assert_redirected_to event_path(code: @event.code)
    assert_not @event.reload.cancelled?
  end

  test "allows a member of an event organization to uncancel the event" do
    @event.organizations << organizations(:rotterdam_centre)
    member = users(:speaker)
    sign_in member

    assert_difference "Log.count", 1 do
      post event_uncancel_path(event_code: @event.code)
    end

    assert_redirected_to event_path(code: @event.code)
    assert_not @event.reload.cancelled?
  end

  # Error cases

  test "requires authentication" do
    assert_no_difference "Log.count" do
      post event_uncancel_path(event_code: @event.code)
    end

    assert_redirected_to new_user_session_path
    assert @event.reload.cancelled?
  end

  test "requires authorization" do
    sign_in @other_user

    assert_no_difference "Log.count" do
      post event_uncancel_path(event_code: @event.code)
    end

    assert_redirected_to root_url
    assert_equal I18n.t("flash.general.unauthorized"), flash[:error]
    assert @event.reload.cancelled?
  end

  test "redirects with formatted flash error and skips ahoy when service fails with validation hash" do
    sign_in @owner
    failure_response = ApplicationService::Response.new(false, nil, {title: ["can't be blank"]})

    Events::Uncancel.stub(:call, failure_response) do
      assert_no_difference "Ahoy::Event.count" do
        post event_uncancel_path(event_code: @event.code)
      end
    end

    assert_redirected_to event_path(code: @event.code)
    assert_equal "can't be blank", flash[:error]
    assert_nil flash[:notice]
  end

  test "redirects with flash error and skips ahoy when service fails with string error" do
    sign_in @owner
    failure_response = ApplicationService::Response.new(false, nil, "User is not authorized to uncancel event")

    Events::Uncancel.stub(:call, failure_response) do
      assert_no_difference "Ahoy::Event.count" do
        post event_uncancel_path(event_code: @event.code)
      end
    end

    assert_redirected_to event_path(code: @event.code)
    assert_equal "User is not authorized to uncancel event", flash[:error]
    assert_nil flash[:notice]
  end

  # Edge cases

  test "GET cannot uncancel the event because the route only accepts POST" do
    sign_in @owner
    path = event_uncancel_path(event_code: @event.code)

    assert_equal "POST", Rails.application.routes.named_routes[:event_uncancel].verb

    # The route is POST-only, so a GET on this path never reaches
    # EventsController#uncancel and must not change the state of the event.
    get path

    assert_not_equal I18n.t("flash.events.uncancelled"), flash[:notice]

    @event.reload
    assert @event.cancelled?
    assert_equal "Weather conditions", @event.cancel_reason
  end
end
