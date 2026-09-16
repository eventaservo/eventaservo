# frozen_string_literal: true

require "test_helper"

class Organization::AdminsTest < ActiveSupport::TestCase
  test "returns only the users marked as admin of the organization" do
    organization = create(:organization)
    admin = create(:user)
    regular_member = create(:user)
    create(:organization_user, organization: organization, user: admin, admin: true)
    create(:organization_user, organization: organization, user: regular_member, admin: false)

    admins = organization.admins

    assert_includes admins, admin
    assert_not_includes admins, regular_member
  end

  test "returns every admin of the organization" do
    organization = create(:organization)
    first_admin = create(:user)
    second_admin = create(:user)
    create(:organization_user, organization: organization, user: first_admin, admin: true)
    create(:organization_user, organization: organization, user: second_admin, admin: true)

    admins = organization.admins

    assert_equal 2, admins.count
    assert_includes admins, first_admin
    assert_includes admins, second_admin
  end

  test "does not return users that are admin of another organization" do
    organization = create(:organization)
    other_organization = create(:organization)
    other_organization_admin = create(:user)
    create(:organization_user, organization: other_organization, user: other_organization_admin, admin: true)

    admins = organization.admins

    assert_empty admins
    assert_includes other_organization.admins, other_organization_admin
  end

  test "returns an empty relation when the organization has no admins" do
    organization = create(:organization)

    admins = organization.admins

    assert_kind_of ActiveRecord::Relation, admins
    assert_empty admins
  end
end
