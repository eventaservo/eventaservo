# frozen_string_literal: true

require "test_helper"

class Users::MemberOfEventOrganizationsQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @event = events(:valid_event)
    # Organizations, organization_users and organization_events have no fixtures
    # yet, so this graph is built with FactoryBot.
    @organization = create(:organization)
  end

  # -- Return contract --

  test "returns an ActiveRecord relation instead of a boolean" do
    assert_kind_of ActiveRecord::Relation, query.call
  end

  # -- Member of the event organizations --

  test "returns the organization of the event the user is a member of" do
    link_to_event(@organization)
    create(:organization_user, organization: @organization, user: @user)

    assert_equal [@organization], query.call.to_a
  end

  test "returns every organization of the event the user is a member of" do
    other_organization = create(:organization)

    link_to_event(@organization)
    link_to_event(other_organization)
    create(:organization_user, organization: @organization, user: @user)
    create(:organization_user, organization: other_organization, user: @user)

    assert_equal [@organization.id, other_organization.id].sort, query.call.map(&:id).sort
  end

  test "returns the organization when the user is an administrator of it" do
    link_to_event(@organization)
    create(:organization_user, :admin, organization: @organization, user: @user)

    assert_equal [@organization], query.call.to_a
  end

  # -- Not a member of the event organizations --

  test "returns an empty relation when the user is not a member of any organization of the event" do
    link_to_event(@organization)

    assert_empty query.call
  end

  test "returns an empty relation when the user is a member of an organization that is not linked to the event" do
    link_to_event(@organization)
    create(:organization_user, organization: create(:organization), user: @user)

    assert_empty query.call
  end

  test "returns an empty relation when the event has no organizations" do
    create(:organization_user, organization: @organization, user: @user)

    assert_empty query.call
  end

  private

  # @return [Users::MemberOfEventOrganizationsQuery] query under test
  def query
    Users::MemberOfEventOrganizationsQuery.new(user: @user, event: @event)
  end

  # Associates the given organization with the event under test.
  #
  # @param organization [Organization] organization to link
  #
  # @return [void]
  def link_to_event(organization)
    @event.organizations << organization
  end
end
