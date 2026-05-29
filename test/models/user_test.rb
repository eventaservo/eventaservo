# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :string
#  admin                  :boolean          default(FALSE)
#  authentication_token   :string(30)       uniquely indexed
#  avatar                 :string
#  birthday               :date
#  city                   :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string           uniquely indexed
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  disabled               :boolean          default(FALSE), indexed
#  email                  :string           default(""), not null, uniquely indexed
#  encrypted_password     :string           default(""), not null
#  events_count           :integer          default(0), indexed
#  failed_attempts        :integer          default(0), not null
#  image                  :string
#  instruo                :jsonb            not null
#  jwt_token              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  ligiloj                :jsonb            not null
#  locked_at              :datetime
#  mailings               :jsonb
#  name                   :string
#  prelego                :jsonb            not null
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string           uniquely indexed
#  sign_in_count          :integer          default(0), not null
#  system_account         :boolean          default(FALSE)
#  ueacode                :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string           uniquely indexed
#  username               :string
#  webcal_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer
#

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should validate presence of name" do
    user = User.new(email: "test@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:name], "devas esti kompletigita"
  end

  test "should validate presence of email" do
    user = User.new(name: "Test User", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "devas esti kompletigita"
  end

  test "should validate uniqueness of email (case insensitive)" do
    create(:user, email: "test@example.com")
    user = build(:user, email: "TEST@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email], "ne estas disponebla"
  end

  test "FactoryBot should be valid" do
    user = build(:user)
    assert user.valid?
  end

  test "should validate uniqueness of username (case insensitive)" do
    create(:user, username: "testuser")
    user = build(:user, username: "TESTUSER")
    assert_not user.valid?
    assert_includes user.errors[:username], "ne estas disponebla"
  end

  test "returns true if the same username is used on a disabled user" do
    create(:user, username: "username", disabled: true)
    user = build(:user, username: "username")
    assert user.valid?
  end

  test "should belong to country" do
    user = User.new
    assert_respond_to user, :country
  end

  test "default scope should return only enabled users" do
    initial_enabled_count = User.count
    initial_total_count = User.unscoped.count

    create(:user)
    assert_equal initial_enabled_count + 1, User.count

    create(:user, disabled: true)
    assert_equal initial_enabled_count + 1, User.count
    assert_equal initial_total_count + 2, User.unscoped.count
  end

  test "should not be able to delete an user with events" do
    user = create(:user)
    create(:event, user:)
    assert_equal false, user.destroy
  end

  test "should not be able to delete an user with organizations" do
    user = create(:user)
    OrganizationUser.create(organization: create(:organization), user:)
    assert_equal false, user.destroy
  end

  test "JWT Token must be created automatically for new users on save" do
    user = build(:user)
    assert_nil user.jwt_token
    user.save
    assert_instance_of String, user.jwt_token
  end

  test "active? returns false when user is not confirmed" do
    user = create(:user)
    user.confirmed_at = nil
    assert_not user.active?
  end

  test "active? returns false when the user never logged in" do
    user = create(:user)
    user.last_sign_in_at = nil
    assert_not user.active?
  end

  test "active? returns true when the user logged in at least once" do
    user = create(:user)
    assert user.active?
  end

  test "generate_webcal_token! should generate a new webcal token" do
    user = create(:user)
    old_token = user.webcal_token
    user.generate_webcal_token!
    assert_not_equal old_token, user.webcal_token
  end

  test "owner_of? should return true if user is owner of event" do
    user = create(:user)
    event = create(:event, user:)
    assert user.owner_of?(event)
  end

  test "owner_of? should return false if user is not owner of event" do
    user = create(:user)
    event = create(:event, user:)
    other_user = create(:user)
    assert_not other_user.owner_of?(event)
  end

  test "has_public_contact? returns false if user has no public contact" do
    user = create(:user)
    assert_equal false, user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a personal website" do
    user = create(:user)
    user.persona_retejo = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a YouTube" do
    user = create(:user)
    user.youtube = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a Telegram" do
    user = create(:user)
    user.telegram = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a Instagram" do
    user = create(:user)
    user.instagram = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a Twitter" do
    user = create(:user)
    user.twitter = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a Facebook" do
    user = create(:user)
    user.facebook = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "has_public_contact? returns true when user has a vk" do
    user = create(:user)
    user.vk = "https://example.com"
    user.save
    assert user.has_public_contact?
  end

  test "merge_to should merge accounts" do
    user1 = create(:user)
    user2 = create(:user)

    # Creates an event for user1
    create(:event, user: user1)
    assert_equal 1, user1.events.count

    # Creates an organization for user1
    organization = create(:organization)
    OrganizationUser.create(organization:, user: user1)
    assert_equal 1, user1.organizations.count

    # Merge user1 to user2
    assert_equal 0, user2.events.count
    assert_equal 0, user2.organizations.count
    user1.merge_to(user2.id)
    assert_equal 1, user2.events.count
    assert_equal 1, user2.organizations.count

    assert user1.destroy
  end

  test "merge_to should return false if trying to merge to same account" do
    user = create(:user)
    assert_equal false, user.merge_to(user.id)
  end
end
