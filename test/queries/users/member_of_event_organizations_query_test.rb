# frozen_string_literal: true

require "test_helper"

class Users::MemberOfEventOrganizationsQueryTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @event = create(:event)
    @organization = create(:organization)
  end

  test "returns true when the user is a member of one of the event organizations" do
    @event.organizations << @organization
    create(:organization_user, organization: @organization, user: @user)

    assert Users::MemberOfEventOrganizationsQuery.new(user: @user, event: @event).call
  end

  test "returns false when the user is not a member of the event organizations" do
    @event.organizations << @organization

    assert_not Users::MemberOfEventOrganizationsQuery.new(user: @user, event: @event).call
  end

  test "returns false when the user is a member of an organization that is not related to the event" do
    @event.organizations << @organization
    create(:organization_user, organization: create(:organization), user: @user)

    assert_not Users::MemberOfEventOrganizationsQuery.new(user: @user, event: @event).call
  end

  test "returns false when the event has no organizations" do
    create(:organization_user, organization: @organization, user: @user)

    assert_not Users::MemberOfEventOrganizationsQuery.new(user: @user, event: @event).call
  end

  test "returns true when the user is an administrator of the event organization" do
    @event.organizations << @organization
    create(:organization_user, :admin, organization: @organization, user: @user)

    assert Users::MemberOfEventOrganizationsQuery.new(user: @user, event: @event).call
  end
end
