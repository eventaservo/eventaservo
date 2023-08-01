# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :string
#  admin                  :boolean          default(FALSE)
#  authentication_token   :string(30)
#  avatar                 :string
#  birthday               :date
#  city                   :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  disabled               :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  events_count           :integer          default(0)
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
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  system_account         :boolean          default(FALSE)
#  ueacode                :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  username               :string
#  webcal_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer          default(99999)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_disabled              (disabled)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_events_count          (events_count)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
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
end
