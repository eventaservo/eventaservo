# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id           :bigint           not null, primary key
#  address      :string
#  city         :string
#  display_flag :boolean          default(TRUE)
#  email        :string
#  logo         :string
#  major        :boolean          default(FALSE)
#  name         :string           not null, indexed
#  official     :boolean          default(FALSE)
#  partner      :boolean          default(FALSE)
#  phone        :string
#  short_name   :string           not null, indexed
#  url          :string
#  youtube      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :integer          default(99999)
#
class Organization < ApplicationRecord
  has_paper_trail
  has_one_attached :logo
  has_rich_text :description
  has_many :organization_users, dependent: :destroy
  has_many :organization_events, dependent: :destroy
  has_many :users, through: :organization_users
  has_many :uzantoj, through: :organization_users, source: :user # @deprecated use .users
  has_many :events, through: :organization_events
  has_many :eventoj, through: :organization_events, source: :event # @deprecated use .events
  belongs_to :country

  before_validation :normalize_urls

  validates :name, :short_name, presence: true
  validates :short_name, uniqueness: {case_sensitive: false}
  validates :short_name, format: {with: /\A[a-zA-Z0-9_\-ĈĉĴĵĜĝĤĥŜŝŬŭÜüÀàÁáÂâÄäÅåÈèÉéÊêĘęėëÍíÎîìïÇçĆćČčŁłÓóÔôÖöØøòõōŚśŠšßÚúùûÝýŹźŻżŽž]*\z/, message: "enhavas spaco(j)n aŭ nevalida(j)n signo(j)n"}

  # Mains organizations are UEA and TEJO
  scope :mains, -> { where(major: true) }

  # Listas la organizatojn kiujn la uzanto rajtas aldoni al la eventoj
  # Se la uzando estas admin, li rajtas aldoni iun ajnan organizojn
  # @param [Model] user
  # @return [ActiveRecordRelation]
  #
  def self.by_user(user)
    if user.admin?
      Organization.all.order(:name)
    else
      joins(:uzantoj).where(organization_users: {user_id: user.id})
    end
  end

  # Listigas la uzantojn kiu ESTAS administrantoj de la Organizo
  def administrantoj
    users_ids = organization_users.where(admin: true).pluck(:user_id)
    User.where(id: users_ids)
  end

  # Listigas la uzantojn kiu NE estas administrantoj de la Organizo
  def ne_estroj
    users_ids = organization_users.where(admin: false).pluck(:user_id)
    User.where(id: users_ids)
  end

  # Listigas ĉiujn membrojn el organizo (administrantoj kaj ne-administrantoj)
  # @deprecated use .users
  def membroj
    User.where(id: organization_users.pluck(:user_id))
  end

  def full_name
    "#{name} (#{short_name})"
  end

  # Serĉas laŭ vorto la organizojn
  #
  def self.serchi(vorto)
    where("unaccent(name) ilike unaccent(:v) OR unaccent(short_name) ilike unaccent(:v)", v: "%#{vorto.tr("''", "")}%")
  end

  def full_address
    adr = []
    adr << address unless address.blank?
    adr << city unless city.blank?
    adr << country.code.upcase unless country.nil?
    adr.compact.join(", ")
  end

  def normalize_urls
    self.url = UrlNormalizer.new(url).call
    self.youtube = UrlNormalizer.new(youtube).call
  end

  def remove_user(user)
    return false if organization_users.count == 1

    OrganizationUser.find_by(user_id: user.id, organization_id: id).destroy
  end

  def self.ransackable_associations(auth_object = nil)
    ["country", "eventoj", "events", "logo_attachment", "logo_blob", "organization_events", "organization_users",
      "rich_text_description", "users", "uzantoj", "versions"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "city", "country_id", "created_at", "display_flag", "email", "id", "logo", "major", "name", "official",
      "partner", "phone", "short_name", "updated_at", "url", "youtube"]
  end
end
