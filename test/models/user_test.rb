# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "uzanto validas" do
    assert build_stubbed(:uzanto).valid?
  end

  test "uzanto ne validas sen nomo" do
    assert build_stubbed(:uzanto, name: nil).invalid?
  end

  test "uzando ne validas sen retpostadreso" do
    assert build_stubbed(:uzanto, email: nil).invalid?
  end

  test "uzanto ne validas sen lando" do
    assert build_stubbed(:uzanto, country_id: nil).invalid?
  end

  test "retpostadreso devas esti ne uzata" do
    create(:uzanto, email: "example@example.com")
    new_user = build(:uzanto, email: "example@example.com")
    assert new_user.invalid?
  end

  test "ne permesas forigi uzant-konton se ĝi ankoraŭ havas eventojn rilatajn" do
    user = create(:uzanto)
    FactoryBot.create(:evento, user_id: user.id)

    assert_not user.destroy
  end

  test "ne permesas forigi uzant-konton se ĝi ankoraŭ havas organizojn rilatajn" do
    user = create(:uzanto)

    organization = create(:organization)
    OrganizationUser.create(organization_id: organization.id, user_id: user.id)

    assert_not user.destroy
  end

  test "JWT Token must be created automatically for new users" do
    user = FactoryBot.build(:user)

    assert user.jwt_token.nil?
    user.save
    assert user.jwt_token.present?
  end
end
