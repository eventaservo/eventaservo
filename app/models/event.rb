# frozen_string_literal: true

# Eventaj dateno
class Event < ApplicationRecord
  is_impressionable # Por kalkuli la paĝvizitojn

  has_many_attached :uploads

  include Code

  belongs_to :user
  belongs_to :country
  has_many :participants, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates :title, :description, :city, :country_id, :date_start, :date_end, :code, presence: true
  validates_length_of :description, maximum: 400
  validates :code, uniqueness: true, on: :create
  validate :end_after_start
  before_save :format_event_data

  geocoded_by :full_address
  after_validation :geocode, if: :require_geocode?

  default_scope { where(deleted: false) }
  scope :deleted, -> { unscoped.where(deleted: true) }
  scope :venontaj, -> { where('date_start >= :date OR date_end >= :date', date: Date.today) }
  scope :pasintaj, -> { where('end_date < ?', Date.today) }
  scope :by_continent, ->(name) { joins(:country).where(countries: { continent: name }) }
  scope :by_country_id, ->(id) { where(country_id: id) }
  scope :by_country_name, ->(name) { joins(:country).where(countries: { name: name }) }
  scope :by_city, ->(city) { where(city: city) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_username, ->(username) { joins(:user).where(users: { username: username }) }
  scope :without_location, -> { where(latitude: nil) }
  scope :online, -> { where(online: true) }
  scope :not_online, -> { where(online: false) }

  def self.grouped_by_months
    order(:date_start).group_by { |m| m.date_start.beginning_of_month }
  end

  def self.count_by_continents
    joins(:country)
      .select('countries.continent as name', 'count(events.id)')
      .group('countries.continent')
      .order('countries.continent')
  end

  def self.count_by_country
    joins(:country)
      .select('countries.name', 'countries.code', 'countries.continent', 'count(events.id)')
      .group('countries.name, countries.code', 'countries.continent')
      .order('countries.name')
  end

  def self.count_by_cities
    select('city as name', 'count(id)').group(:city).order(:city)
  end

  # Malapareigu la eventon, sed ne forviŝu ĝin
  def delete!
    update_attribute(:deleted, true)
  end

  # Reapegiru la eventon
  def undelete!
    update_attribute(:deleted, false)
  end

  def self.search(search)
    all if search.blank?

    joins(:country)
      .where('unaccent(events.title) ilike unaccent(:search) OR
              unaccent(events.description) ilike unaccent(:search) OR
              unaccent(events.content) ilike unaccent(:search) OR
              unaccent(events.city) ilike unaccent(:search) OR
              unaccent(countries.name) ilike unaccent(:search)',
             search: "%#{search.tr(' ', '%').downcase}%").order('events.date_start')
  end

  def full_address
    [address, city, country.try(:code).try(:upcase)].compact.join(', ')
  end

  def require_geocode?
    return false if online

    address_changed? || city_changed? || country_id_changed?
  end

  def location_defined?
    latitude.present? && longitude.present?
  end

  private

    def end_after_start
      return if date_start.blank? || date_end.blank?

      errors.add(:date_end, 'ne povas okazi antaŭ la komenca dato') if date_end < date_start
    end

    # Formatas la eventon laŭ normala formato
    def format_event_data
      self.title = fix_title(title)
      self.city = city.tr('/', '')
      self.site = fix_site(site)

      if self.online
        self.city = 'Reta urbo'
        self.country_id = 99999
        self.latitude = nil
        self.longitude = nil
      end
    end

    def fix_title(title)
      if [title.downcase, title.upcase].include?(title)
        title.titleize
      else
        title
      end
    end

    def fix_site(site)
      return if site.nil?

      if site[%r{\Ahttp:\/\/}] || site[%r{\Ahttps:\/\/}]
        site.strip
      elsif site.strip.empty?
        nil
      else
        "http://#{site.strip}"
      end
    end
end
