# frozen_string_literal: true

require "test_helper"

class EventsController::CancelTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:user)
    @admin = users(:admin_user)
    @other_user = users(:teacher)
    @event = events(:valid_event)
  end

  # Success cases

  test "cancels the event with a reason, creates audit log, and tracks with ahoy" do
    sign_in @owner
    reason = "Weather conditions"

    assert_difference ["Log.count", "Ahoy::Event.count"], 1 do
      post event_cancel_path(event_code: @event.code), params: {cancel_reason: reason}
    end

    assert_redirected_to event_path(code: @event.code)
    assert_equal I18n.t("flash.events.cancelled"), flash[:notice]

    @event.reload
    assert @event.cancelled?
    assert_equal reason, @event.cancel_reason

    log = Log.last
    assert_equal "Event cancelled", log.text
    assert_equal @owner, log.user
    assert_equal @event, log.loggable
  end

  test "cancels the event using short_url" do
    sign_in @owner
    @event.update!(short_url: "rails-conf-2024")
    reason = "Weather conditions"

    post event_cancel_path(event_code: @event.short_url), params: {cancel_reason: reason}

    assert_redirected_to event_path(code: @event.short_url)
    @event.reload
    assert @event.cancelled?
    assert_equal reason, @event.cancel_reason
  end

  test "allows an admin to cancel the event" do
    sign_in @admin

    assert_difference "Log.count", 1 do
      post event_cancel_path(event_code: @event.code), params: {cancel_reason: "Admin cancellation"}
    end

    assert_redirected_to event_path(code: @event.code)
    assert @event.reload.cancelled?
  end

  test "allows a member of an event organization to cancel the event" do
    @event.organizations << organizations(:rotterdam_centre)
    member = users(:speaker)
    sign_in member

    assert_difference "Log.count", 1 do
      post event_cancel_path(event_code: @event.code), params: {cancel_reason: "Venue issue"}
    end

    assert_redirected_to event_path(code: @event.code)
    assert @event.reload.cancelled?
  end

  # Error cases

  test "requires authentication" do
    assert_no_difference "Log.count" do
      post event_cancel_path(event_code: @event.code)
    end

    assert_redirected_to new_user_session_path
    assert_not @event.reload.cancelled?
  end

  test "requires authorization" do
    sign_in @other_user

    assert_no_difference "Log.count" do
      post event_cancel_path(event_code: @event.code)
    end

    assert_redirected_to root_url
    assert_equal I18n.t("flash.general.unauthorized"), flash[:error]
    assert_not @event.reload.cancelled?
  end

  test "redirects with formatted flash error and skips ahoy when service fails with validation hash" do
    sign_in @owner
    failure_response = ApplicationService::Response.new(false, nil, {title: ["can't be blank"]})

    Events::Cancel.stub(:call, failure_response) do
      assert_no_difference "Ahoy::Event.count" do
        post event_cancel_path(event_code: @event.code), params: {cancel_reason: "Weather"}
      end
    end

    assert_redirected_to event_path(code: @event.code)
    assert_equal "can't be blank", flash[:error]
    assert_nil flash[:notice]
  end

  test "redirects with flash error and skips ahoy when service fails with string error" do
    sign_in @owner
    failure_response = ApplicationService::Response.new(false, nil, "User is not authorized to cancel event")

    Events::Cancel.stub(:call, failure_response) do
      assert_no_difference "Ahoy::Event.count" do
        post event_cancel_path(event_code: @event.code)
      end
    end

    assert_redirected_to event_path(code: @event.code)
    assert_equal "User is not authorized to cancel event", flash[:error]
    assert_nil flash[:notice]
  end
end
