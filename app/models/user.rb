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
#  country_id             :integer
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
class User < ApplicationRecord
  acts_as_token_authenticatable
  has_paper_trail

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable, :lockable, :trackable,
    :omniauthable, omniauth_providers: %i[facebook]

  has_one_attached :picture
  store_accessor :mailings, :weekly_summary
  store_accessor :instruo, :instruisto
  store_accessor :prelego, :preleganto
  store_accessor :ligiloj, [:youtube, :telegram, :instagram, :facebook, :vk, :persona_retejo, :twitter]

  before_validation :generate_webcal_token, if: :new_record?
  before_save :generate_username, if: :new_record?
  before_save :subscribe_mailings, if: :new_record?
  before_save :generate_jwt_token, if: :new_record?
  before_save :sanitize_links

  before_destroy :check_for_related_records

  has_many :events
  belongs_to :country, inverse_of: :users
  has_many :organization_users
  has_many :organizations, through: :organization_users # TODO: Evitinda
  has_many :organizoj, through: :organization_users, source: :organization
  has_many :interested_events_relation, class_name: "Participant", dependent: :destroy
  has_many :interested_events, through: :interested_events_relation, source: :event
  has_many :event_reports, class_name: "Event::Report", dependent: :destroy

  validates :name, presence: true
  validates :username, uniqueness: true
  validates :webcal_token, uniqueness: true

  default_scope { where(disabled: false) }

  scope :receives_weekly_summary, -> { where("mailings @> ?", {weekly_summary: "1"}.to_json) }
  scope :admins, -> { where(admin: true) }
  scope :instruistoj, -> { where("instruo ->> 'instruisto' = 'true'") }
  scope :prelegantoj, -> { where("prelego ->> 'preleganto' = 'true'") }
  scope :enabled, -> { where(disabled: false) }
  scope :disabled, -> { unscoped.where(disabled: true) }
  scope :abandoned, -> { where("last_sign_in_at < ?", 2.years.ago) }
  scope :not_confirmed, -> { where(confirmed_at: nil) }

  def self.from_omniauth(auth)
    if where(email: auth.info.email).exists?
      return_user = find_by(email: auth.info.email)
      return_user.provider = auth.provider
      return_user.uid = auth.uid
    else
      return_user =
        create! do |user|
          user.provider = auth.provider
          user.uid = auth.uid
          user.email = auth.info.email || "nova_uzanto_#{rand(1000)}@eventaservo.org"
          user.password = Devise.friendly_token[0, 20]
          user.name = auth.info.name # assuming the user model has a name
          user.image = auth.info.image # assuming the user model has an image
          user.country_id = 99999
          user.skip_confirmation!
        end
      NovaUzantoSciigoJob.perform_later(return_user)
    end

    if !return_user.picture.attached?
      UserServices::CopyImageUrlToProfile.call(user: return_user, url: auth.info.image)
    end

    return_user
  end

  # Returns true if the user if owner of the record (eg. event)
  # returns false otherwise
  #
  # The object must respond to user_id
  #
  # @param object [Object]
  # @return [Boolean]
  def owner_of?(object)
    object.user_id == id
  end

  def organiza_membro_de_evento(evento)
    id.in? evento.organizations.joins(:uzantoj).pluck(:user_id)
  end

  def follower?(record)
    !record.followers.find_by(user_id: self).nil?
  end

  def generate_username(random: false)
    return false if username.present?

    username = ActiveSupport::Inflector.transliterate(name).tr(" ", "_").tr(".", "_").downcase
    username.gsub!(/[^0-9A-Za-z_-]/, "")
    username += SecureRandom.rand(100).to_s if random

    if User.find_by(username: username)
      generate_username(random: true)
    else
      update_attribute(:username, username)
    end
  end

  # Kontrolas ĉu la uzanto estas administranto de organizo.
  #
  # @param [Object] organizo Organizo
  # @return [Boolean] se la uzanto estas administranto
  # @note Ĉiam respondas +true+ se la uzanto estas ES-Admin.
  def administranto?(organizo)
    (in? organizo.administrantoj) || admin
  end

  # Checks if the user has any public contact information fullfilled
  #
  # @return [Boolean]
  def has_public_contact?
    youtube.present? || telegram.present? || instagram.present? || persona_retejo.present? || twitter.present?
  end

  # Serĉas uzanton laŭ teksto
  def self.serchi(teksto)
    User
      .left_joins(:organizations)
      .distinct
      .where('unaccent(users.name) ilike unaccent(:search) OR
              unaccent(users.username) ilike unaccent(:search) OR
              unaccent(organizations.name) ilike unaccent(:search) OR
              unaccent(organizations.short_name) ilike unaccent(:search)',
        search: "%#{teksto.strip.tr(" ", "%").downcase}%")
      .order("users.name")
  end

  # Kunigas la nunan konton kun alia konto-id
  # @since 2.25
  def merge_to(destination_user_id)
    return false if destination_user_id == id

    ActiveRecord::Base.transaction do
      Event.where(user_id: id).update_all(user_id: destination_user_id)
      OrganizationUser.where(user_id: id).update_all(user_id: destination_user_id)
      Log.where(user_id: id).update_all(user_id: destination_user_id)
      User.reset_counters(destination_user_id, :events)
      destroy
    end
  end

  # Return the system account
  #
  # @return [User]
  #
  def self.system_account
    find_by(system_account: true)
  end

  # Returns the user's name with username
  #
  # @return [String]
  def name_with_username
    "#{name} (#{username})"
  end

  # Returns if the user is active
  # Active means he confirmed the email address and logged in at least once
  #
  # @return [Boolean]
  def active?
    !!confirmed_at && !!last_sign_in_at
  end

  # Generates and updates the Webcal token
  #
  # @return [String] the new token
  def generate_webcal_token!
    token = create_webcal_token
    update!(webcal_token: token)

    token
  end

  def generate_webcal_token
    self.webcal_token ||= create_webcal_token
  end

  def self.ransackable_associations(auth_object = nil)
    ["country", "event_reports", "events", "interested_events", "interested_events_relation", "organization_users",
      "organizations", "organizoj", "picture_attachment", "picture_blob", "versions"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["about", "admin", "authentication_token", "avatar", "birthday", "city", "confirmation_sent_at",
      "confirmation_token", "confirmed_at", "country_id", "created_at", "current_sign_in_at", "current_sign_in_ip",
      "disabled", "email", "encrypted_password", "events_count", "failed_attempts", "id", "image", "instruo",
      "jwt_token", "last_sign_in_at", "last_sign_in_ip", "ligiloj", "locked_at", "mailings", "name", "prelego",
      "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count",
      "system_account", "ueacode", "uid", "unconfirmed_email", "unlock_token", "updated_at", "username",
      "webcal_token"]
  end

  def to_combobox_display
    "#{name} (#{username})"
  end

  private

  # Generate JWT Token for API v2 before saving the user
  def generate_jwt_token
    payload = {id: id}
    jwt_token = JWT.encode(payload, Rails.application.credentials.dig(:jwt, :secret), "HS256")
    self.jwt_token = jwt_token
  end

  def subscribe_mailings
    self.weekly_summary = "1"
  end

  def sanitize_links
    return if ligiloj.keys.empty?

    ligiloj.keys.each do |site|
      next if site.empty?

      address = ligiloj[site]
      if address[%r{\Ahttp://}] || address[%r{\Ahttps://}]
        address.strip
      elsif address.strip.empty?
        nil
      else
        ligiloj[site] = "https://#{address.strip}"
      end
    end
  end

  # Kontrolas ĉu la uzanto ankoraŭ havas iun registron en ES antaŭ forigi ĝin
  # Se jes, ne permesu forigi la konton.
  #
  # @since 2.25
  def check_for_related_records
    if Event.where(user_id: id).any?
      logger.error "*** Ne eblas forigi la konton (ID:#{id}) ĉar ĝi ankoraŭ havas eventojn rilatajn. ***"
      throw :abort
    end

    if OrganizationUser.where(user_id: id).any?
      logger.error "*** Ne eblas forigi la konton (ID:#{id} ĉar ĝi ankoraŭ estas membro de organizo. ***"
      throw :abort
    end
  end

  # Creates (but not save) a new webcal token
  #
  # @return [String]
  def create_webcal_token
    Random.hex(4)
  end
end
