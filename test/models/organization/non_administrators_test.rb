# frozen_string_literal: true

require "test_helper"

class Organization::NonAdministratorsTest < ActiveSupport::TestCase
  test "returns only the members that are not administrators" do
    organization = organizations(:rotterdam_centre)

    non_administrators = organization.non_administrators

    assert_equal 1, non_administrators.count
    assert_includes non_administrators, users(:speaker)
    assert_not_includes non_administrators, users(:teacher)
  end

  test "does not return members of other organizations" do
    assert_includes organizations(:rotterdam_centre).non_administrators, users(:speaker)

    assert_not_includes organizations(:sao_paulo_klubo).non_administrators, users(:speaker)
  end

  test "returns an empty relation when every member is an administrator" do
    non_administrators = organizations(:sao_paulo_klubo).non_administrators

    assert_kind_of ActiveRecord::Relation, non_administrators
    assert_empty non_administrators
  end

  test "returns an empty relation when the organization has no members" do
    non_administrators = organizations(:tokyo_society).non_administrators

    assert_kind_of ActiveRecord::Relation, non_administrators
    assert_empty non_administrators
  end
end
