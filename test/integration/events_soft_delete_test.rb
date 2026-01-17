# frozen_string_literal: true

require "test_helper"

class EventsSoftDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
    @event = create(:event, user: @user)
    @other_user = create(:user)
    @admin_user = create(:user, :admin)
  end

  test "owner successfully soft deletes the event and creates log entry" do
    sign_in @user
    event_to_delete = @event
    initial_count = Event.unscoped.count
    initial_log_count = Log.count

    delete event_path(code: event_to_delete.ligilo)

    assert_redirected_to root_url
    follow_redirect!

    assert_response :success
    assert_match(/Evento sukcese forigita/, response.body)

    assert_equal initial_count, Event.unscoped.count
    assert event_to_delete.reload.deleted

    assert_equal initial_log_count + 1, Log.count
    log = Log.order(created_at: :desc).first
    assert_equal "Event deleted", log.text
    assert_equal @user, log.user
    assert_equal event_to_delete.id, log.loggable_id
    assert_equal "Event", log.loggable_type
  end

  test "admin successfully soft deletes another user's event" do
    other_event = create(:event, user: @other_user)
    sign_in @admin_user
    event_to_delete = other_event
    initial_count = Event.unscoped.count

    delete event_path(code: event_to_delete.ligilo)

    assert_redirected_to root_url
    follow_redirect!

    assert_match(/Evento sukcese forigita/, response.body)
    assert_equal initial_count, Event.unscoped.count
    assert event_to_delete.reload.deleted
  end

  test "unauthorized user denies access and redirects with error message" do
    unauthorized_event = create(:event, user: @other_user)
    sign_in @user

    assert_no_difference -> { Event.unscoped.where(deleted: true).count } do
      delete event_path(code: unauthorized_event.ligilo)
    end

    assert_redirected_to root_url
    follow_redirect!

    assert_match(/Vi ne rajtas/, response.body)
    refute unauthorized_event.reload.deleted
  end

  test "unauthenticated user redirects to sign in page" do
    delete event_path(code: @event.ligilo)
    assert_redirected_to new_user_session_path
  end

  test "organization member allows organization member to delete the event" do
    organization = create(:organization)
    org_event = create(:event, user: @other_user)
    member_user = create(:user)

    organization.users << member_user
    org_event.organizations << organization
    sign_in member_user

    event_to_delete = org_event
    initial_count = Event.unscoped.count

    delete event_path(code: event_to_delete.ligilo)

    assert_redirected_to root_url
    follow_redirect!

    assert_match(/Evento sukcese forigita/, response.body)
    assert_equal initial_count, Event.unscoped.count
    assert event_to_delete.reload.deleted
  end
end
