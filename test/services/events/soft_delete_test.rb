# frozen_string_literal: true

require "test_helper"

class Events::SoftDeleteTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @event = create(:event, user: @user, deleted: false)
  end

  test "marks the event as deleted" do
    service = Events::SoftDelete.new(event: @event, user: @user).call

    assert @event.reload.deleted
  end

  test "creates a log entry" do
    assert_difference("Log.count", 1) do
      Events::SoftDelete.new(event: @event, user: @user).call
    end

    assert_equal "Deleted event #{@event.title}", Log.last.text
    assert_equal @user, Log.last.user
    assert_equal @event.id, Log.last.event_id
  end

  test "returns success" do
    service = Events::SoftDelete.new(event: @event, user: @user).call

    assert service.success?
  end

  test "returns the event" do
    service = Events::SoftDelete.new(event: @event, user: @user).call

    assert_equal @event, service.payload
  end

  test "returns success when user is the owner" do
    event = create(:event, deleted: false, user: @user)
    service = Events::SoftDelete.new(event: event, user: @user).call

    assert service.success?
  end

  test "returns success when user is an admin" do
    admin = create(:user, :admin)
    other_user = create(:user)
    event = create(:event, deleted: false, user: other_user)

    service = Events::SoftDelete.new(event: event, user: admin).call

    assert service.success?
  end

  test "returns success when user is a member of event's organization" do
    organization = create(:organization)
    other_user = create(:user)
    event = create(:event, deleted: false, user: other_user)

    @user.stub(:organiza_membro_de_evento, true) do
      service = Events::SoftDelete.new(event: event, user: @user).call
      assert service.success?
    end
  end

  test "returns failure when user is not authorized" do
    other_user = create(:user)
    event = create(:event, deleted: false, user: other_user)

    service = Events::SoftDelete.new(event: event, user: @user).call

    assert_not service.success?
    assert_equal "User is not authorized to delete event", service.error
  end

  test "returns failure when event update fails" do
    event = create(:event, deleted: false, user: @user)

    event.stub(:update, false) do
      service = Events::SoftDelete.new(event: event, user: @user).call

      assert service.failure?
      assert_not service.success?
      assert_equal "Failed to soft delete event", service.error
    end
  end
end
