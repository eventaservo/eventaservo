# frozen_string_literal: true

require "test_helper"

class Organization::MembersTest < ActiveSupport::TestCase
  test "returns every member of the organization, administrators included" do
    members = organizations(:rotterdam_centre).members

    assert_equal 2, members.count
    assert_includes members, users(:teacher)
    assert_includes members, users(:speaker)
  end

  test "returns the administrators of an organization without regular members" do
    members = organizations(:sao_paulo_klubo).members

    assert_equal 2, members.count
    assert_includes members, users(:teacher_and_speaker)
    assert_includes members, users(:admin_user)
  end

  test "does not return members of other organizations" do
    assert_includes organizations(:rotterdam_centre).members, users(:speaker)

    assert_not_includes organizations(:sao_paulo_klubo).members, users(:speaker)
  end

  test "returns an empty relation when the organization has no members" do
    members = organizations(:tokyo_society).members

    assert_kind_of ActiveRecord::Relation, members
    assert_empty members
  end
end
