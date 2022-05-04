# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'uzanto validas' do
    assert build_stubbed(:uzanto).valid?
  end

  test 'uzanto ne validas sen nomo' do
    assert build_stubbed(:uzanto, name: nil).invalid?
  end

  test 'uzando ne validas sen retpostadreso' do
    assert build_stubbed(:uzanto, email: nil).invalid?
  end

  test 'uzanto ne validas sen lando' do
    assert build_stubbed(:uzanto, country_id: nil).invalid?
  end

  test 'retpostadreso devas esti ne uzata' do
    create(:uzanto, email: 'example@example.com')
    new_user = build(:uzanto, email: 'example@example.com')
    assert new_user.invalid?
  end

  test 'ne permesas forigi uzant-konton se ĝi ankoraŭ havas eventojn rilatajn' do
    user = create(:uzanto)
    FactoryBot.create(:evento, user_id: user.id)

    assert_not user.destroy
  end

  test 'ne permesas forigi uzant-konton se ĝi ankoraŭ havas organizojn rilatajn' do
    user = create(:uzanto)

    organization = create(:organizo)
    OrganizationUser.create(organization_id: organization.id, user_id: user.id)

    assert_not user.destroy
  end

  test 'kunigas uzant-kontojn' do
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

  test 'ne eblas kunigi la saman konton' do
    user = create(:uzanto)
    assert_not user.merge_to(user.id)
  end

  test 'JWT Token must be created automatically for new users' do
    user = FactoryBot.build(:user)

    assert user.jwt_token.nil?
    user.save
    assert user.jwt_token.present?
  end
end
