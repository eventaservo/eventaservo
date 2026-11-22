# frozen_string_literal: true

require "test_helper"

class EventPolicyTest < ActiveSupport::TestCase
  test "allows event owner to edit, update, cancel, uncancel, and destroy" do
    policy = EventPolicy.new(user: users(:user), event: events(:valid_event))

    assert policy.edit?
    assert policy.update?
    assert policy.cancel?
    assert policy.uncancel?
    assert policy.destroy?
  end

  test "allows administrator to manage any event" do
    policy = EventPolicy.new(user: users(:admin_user), event: events(:valid_event))

    assert policy.edit?
    assert policy.destroy?
  end

  test "allows member of an organization linked to the event" do
    event = events(:valid_event)
    event.organizations << organizations(:rotterdam_centre)
    policy = EventPolicy.new(user: users(:speaker), event:)

    assert policy.edit?
    assert policy.update?
    assert policy.cancel?
    assert policy.uncancel?
    assert policy.destroy?
  end

  test "denies unrelated user" do
    policy = EventPolicy.new(user: users(:speaker), event: events(:valid_event))

    assert_not policy.edit?
    assert_not policy.update?
    assert_not policy.cancel?
    assert_not policy.uncancel?
    assert_not policy.destroy?
  end

  test "denies nil user" do
    policy = EventPolicy.new(user: nil, event: events(:valid_event))

    assert_not policy.edit?
  end
end
