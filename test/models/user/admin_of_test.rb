# frozen_string_literal: true

require "test_helper"

class User::AdminOfTest < ActiveSupport::TestCase
  test "returns true when the user is an administrator of the organization" do
    user = users(:teacher)
    organization = organizations(:rotterdam_centre)

    assert user.admin_of?(organization)
  end

  test "returns false when the user is a member without the admin flag" do
    user = users(:speaker)
    organization = organizations(:rotterdam_centre)

    assert_not user.admin_of?(organization)
  end

  test "returns true for ES-Admin users even when not an administrator of the organization" do
    user = users(:admin_user)
    organization = organizations(:rotterdam_centre)

    assert user.admin_of?(organization)
  end
end
