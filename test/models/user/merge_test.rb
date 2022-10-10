# frozen_string_literal: true

require "test_helper"

class User::MergeTest < ActiveSupport::TestCase
  test "kunigas uzant-kontojn" do
    user1 = create(:uzanto)
    user2 = create(:uzanto)

    assert user1.events.count, 0
    create(:evento, user_id: user1.id)
    assert user1.events.count, 1

    assert user1.organizoj.count, 0
    organization = create(:organizo)
    OrganizationUser.create(organization_id: organization.id, user_id: user1.id)
    assert user1.organizoj.count, 1

    assert_not user1.destroy

    assert user2.events.count, 0
    assert user2.organizoj.count, 0
    user1.merge_to(user2.id)
    assert user2.events.count, 1
    assert user2.organizoj.count, 1

    assert user1.destroy
    assert_not user2.destroy
  end

  test "ne eblas kunigi la saman konton" do
    user = create(:uzanto)
    assert_not user.merge_to(user.id)
  end
end
