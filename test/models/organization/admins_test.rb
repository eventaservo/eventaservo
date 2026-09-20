# frozen_string_literal: true

require "test_helper"

class Organization::AdminsTest < ActiveSupport::TestCase
  test "returns only the users marked as admin of the organization" do
    organization = organizations(:rotterdam_centre)

    admins = organization.admins

    assert_includes admins, users(:teacher)
    assert_not_includes admins, users(:speaker)
  end

  test "returns every admin of the organization" do
    organization = organizations(:sao_paulo_klubo)

    admins = organization.admins

    assert_equal 2, admins.count
    assert_includes admins, users(:teacher_and_speaker)
    assert_includes admins, users(:admin_user)
  end

  test "does not return users that are admin of another organization" do
    organization = organizations(:tokyo_society)

    admins = organization.admins

    assert_empty admins
    assert_includes organizations(:sao_paulo_klubo).admins, users(:teacher_and_speaker)
  end

  test "returns an empty relation when the organization has no admins" do
    admins = organizations(:tokyo_society).admins

    assert_kind_of ActiveRecord::Relation, admins
    assert_empty admins
  end
end
