# frozen_string_literal: true

class Organization < ApplicationRecord
  has_paper_trail
  has_one_attached :logo
  has_rich_text :description
  has_many :organization_users, dependent: :destroy
  has_many :organization_events, dependent: :destroy
  has_many :uzantoj, through: :organization_users, source: :user
  has_many :eventoj, through: :organization_events, source: :event
  belongs_to :country

  before_validation :fix_site

  validates :name, :short_name, presence: true
  validates :short_name, uniqueness: { case_sensitive: false }
  validates :short_name, format: { with: /\A[a-zA-Z0-9_\-ĈĉĴĵĜĝĤĥŜŝĴĵŬŭÜüÀàÁáÂâÄäÅåÈèÉéÊêĘęėëÍíÎîìïÇçĆćČčŁłÓóÔôÖöØøòõōŚśŠšßÚúÜüùûÝýŹźŻżŽž]*\z/, message: 'enhavas spaco(j)n aŭ nevalida(j)n signo(j)n' }

  # Listas la organizatojn kiujn la uzanto rajtas aldoni al la eventoj
  # Se la uzando estas admin, li rajtas aldoni iun ajnan organizojn
  # @param [Model] user
  # @return [ActiveRecordRelation]
  #
  def self.by_user(user)
    if user.admin?
      Organization.all.order(:name)
    else
      joins(:uzantoj).where(organization_users: { user_id: user.id })
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
  def membroj
    User.where(id: organization_users.pluck(:user_id))
  end

  def full_name
    "#{name} (#{short_name})"
  end

  # Serĉas laŭ vorto la organizojn
  #
  def self.serchi(vorto)
    where('unaccent(name) ilike unaccent(:v) OR unaccent(short_name) ilike unaccent(:v)', v: "%#{vorto.tr("''", '')}%")
  end

  def full_address
    adr = []
    adr << address unless address.blank?
    adr << city unless city.blank?
    adr << country.code.upcase unless country.nil?
    adr.compact.join(', ')
  end

  def fix_site
    site = self.url
    return if site.nil?

    self.url =
      if site[%r{\Ahttp:\/\/}] || site[%r{\Ahttps:\/\/}]
        site.strip
      elsif site.strip.empty?
        nil
      else
        "http://#{site.strip}"
      end
  end
end
