# frozen_string_literal: true

require "test_helper"

class UserServices::DisableTest < ActiveSupport::TestCase
  test "sets disabled to true" do
    user = users(:user)

    UserServices::Disable.call(user)

    assert user.reload.disabled
  end

  test "returns true" do
    user = users(:user)

    result = UserServices::Disable.call(user)

    assert result.success?
  end

  test "moves user events to system account" do
    user = users(:user)
    system_user = users(:system_user)
    event = create(:event, user: user)

    assert_equal user.id, event.user_id

    UserServices::Disable.call(user)

    assert_equal system_user.id, event.reload.user_id
  end

  test "removes the user from its organizations" do
    user = users(:user)
    create(:organization_user, user: user)
    organization = user.organizations.first

    another_user = create(:user)
    create(:organization_user, :admin, user: another_user, organization: organization)

    assert_equal 1, user.organizations.count

    UserServices::Disable.call(user)

    assert_equal 0, user.organizations.count
  end

  test "returns false if the user is the only member of the organization" do
    user = users(:user)
    organization = create(:organization)
    OrganizationUser.destroy_all
    OrganizationUser.create!(user: user, organization: organization)

    assert_equal 1, user.organizations.count

    result = UserServices::Disable.call(user)

    assert_not result.success?
  end
end
