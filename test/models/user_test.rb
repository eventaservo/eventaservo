require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
  end

  context "Associations" do
    should belong_to(:country)
  end

  context "Validations" do
    should validate_presence_of(:name)
    should validate_presence_of(:email)
    should validate_uniqueness_of(:email).case_insensitive
  end

  test "uzanto validas" do
    assert build(:user).valid?
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

  class OwnerOf < ActiveSupport::TestCase
    def test_return_true_if_user_is_owner_of_event
      user = create(:user)
      event = create(:event, user: user)

      assert user.owner_of?(event)
    end

    def test_return_false_if_user_if_not_owner_of_event
      user1 = create(:user)
      event = create(:event, user: user1)
      user2 = create(:user)
      assert_not user2.owner_of?(event)
    end
  end
end
