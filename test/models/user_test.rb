# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
  end

  test "uzanto validas" do
    assert build(:user).valid?
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
    new_user = build(:uzanto, email: @user.email)
    assert new_user.invalid?
  end

  test "ne permesas forigi uzant-konton se ĝi ankoraŭ havas eventojn rilatajn" do
    FactoryBot.create(:evento, user_id: @user.id)

    assert_not @user.destroy
  end

  test "ne permesas forigi uzant-konton se ĝi ankoraŭ havas organizojn rilatajn" do
    organization = create(:organization)
    OrganizationUser.create(organization_id: organization.id, user_id: @user.id)

    assert_not @user.destroy
  end

  test "JWT Token must be created automatically for new users" do
    user = FactoryBot.build(:user)

    assert user.jwt_token.nil?
    user.save
    assert user.jwt_token.present?
  end

  test ".active?" do
    assert_not @user.active?

    @user.update(confirmed_at: Time.zone.today)
    assert_not @user.active?

    @user.update(last_sign_in_at: Time.zone.today)
    assert @user.active?
  end

  test ".generate_webcal_token!" do
    original_webcal_token = @user.webcal_token
    assert original_webcal_token.present?

    @user.generate_webcal_token!
    assert_not_equal @user.webcal_token, original_webcal_token
  end
end
