# frozen_string_literal: true

require "test_helper"

class Organizations::DeleteTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin_user)
    @source_org = organizations(:rotterdam_centre)
    @target_org = organizations(:sao_paulo_klubo)
    @event = events(:valid_event)
  end

  # Success cases

  test "transfers events to target organization, removes all members, destroys organization, and logs deletion" do
    @source_org.organization_events.create!(event: @event)
    initial_members_count = @source_org.organization_users.count
    assert_operator initial_members_count, :>, 0

    result = nil
    assert_difference "Organization.count", -1 do
      assert_difference "Log.count", 1 do
        result = Organizations::Delete.call(
          organization: @source_org,
          user: @admin,
          target_organization: @target_org
        )
      end
    end

    assert result.success?
    assert_equal 1, result.payload.transferred_events_count
    assert_equal initial_members_count, result.payload.removed_members_count
    assert_equal @target_org, result.payload.target_organization

    assert_not Organization.exists?(@source_org.id)
    assert_empty OrganizationUser.where(organization_id: @source_org.id)
    assert_empty OrganizationEvent.where(organization_id: @source_org.id)
    assert_includes @target_org.reload.events, @event

    log = Log.order(:id).last
    assert_equal @admin, log.user
    assert_equal @target_org, log.loggable
    assert_includes log.text, @source_org.name
  end

  test "deduplicates events already linked to both source and target organizations" do
    @source_org.organization_events.create!(event: @event)
    @target_org.organization_events.create!(event: @event)

    result = Organizations::Delete.call(
      organization: @source_org,
      user: @admin,
      target_organization: @target_org
    )

    assert result.success?
    assert_equal 0, result.payload.transferred_events_count
    assert_equal 1, result.payload.deduplicated_events_count
    assert_equal 1, OrganizationEvent.where(organization_id: @target_org.id, event_id: @event.id).count
    assert_not Organization.exists?(@source_org.id)
  end

  test "deletes organization with no events without requiring a target organization" do
    @source_org.organization_events.destroy_all
    initial_members_count = @source_org.organization_users.count

    result = nil
    assert_difference "Organization.count", -1 do
      assert_difference "Log.count", 1 do
        result = Organizations::Delete.call(
          organization: @source_org,
          user: @admin
        )
      end
    end

    assert result.success?
    assert_equal 0, result.payload.transferred_events_count
    assert_equal initial_members_count, result.payload.removed_members_count
    assert_nil result.payload.target_organization
    assert_not Organization.exists?(@source_org.id)
    assert_empty OrganizationUser.where(organization_id: @source_org.id)
  end

  # Error cases

  test "fails with target_required when organization has events and no target is provided" do
    @source_org.organization_events.create!(event: @event)

    result = nil
    assert_no_difference ["Organization.count", "OrganizationUser.count", "Log.count"] do
      result = Organizations::Delete.call(
        organization: @source_org,
        user: @admin
      )
    end

    assert result.failure?
    assert_equal :target_required, result.error
    assert Organization.exists?(@source_org.id)
  end

  test "fails with same_organization when target matches source organization" do
    result = nil
    assert_no_difference ["Organization.count", "OrganizationUser.count", "Log.count"] do
      result = Organizations::Delete.call(
        organization: @source_org,
        user: @admin,
        target_organization: @source_org
      )
    end

    assert result.failure?
    assert_equal :same_organization, result.error
    assert Organization.exists?(@source_org.id)
  end

  test "fails with forbidden when user is not an admin" do
    regular_user = users(:teacher)

    result = nil
    assert_no_difference ["Organization.count", "OrganizationUser.count", "Log.count"] do
      result = Organizations::Delete.call(
        organization: @source_org,
        user: regular_user,
        target_organization: @target_org
      )
    end

    assert result.failure?
    assert_equal :forbidden, result.error
    assert Organization.exists?(@source_org.id)
  end
end
