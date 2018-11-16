# frozen_string_literal: true

# Eventaj dateno
class Event < ApplicationRecord
  include Code

  belongs_to :user
  belongs_to :country
  has_many :participants, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates_presence_of :title, :description, :city, :country_id, :date_start, :date_end, :code
  validates_uniqueness_of :code
  validate :end_after_start

  default_scope { where(deleted: false) }
  scope :deleted, -> { unscoped.where(deleted: true) }
  scope :venontaj, -> { where('date_start >= ?', Date.today) }
  scope :pasintaj, -> { where('date_start < ?', Date.today) }
  scope :by_country_id, ->(id) { where(country_id: id) }
  scope :by_country_name, ->(name) { joins(:country).where(countries: { name: name }) }
  scope :by_city, ->(city) { where(city: city) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_username, ->(username) { joins(:user).where(users: { username: username}) }

  def self.grouped_by_months
    order(:date_start).group_by { |m| m.date_start.beginning_of_month }
  end

  def self.count_by_country
    joins(:country).select('countries.name', 'count(events.id)').group('countries.name').order('countries.name')
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
    all unless search.present?

    joins(:country)
      .where('unaccent(events.title) ilike unaccent(:search) OR
              unaccent(events.description) ilike unaccent(:search) OR
              unaccent(events.content) ilike unaccent(:search) OR
              unaccent(events.city) ilike unaccent(:search) OR
              unaccent(countries.name) ilike unaccent(:search)',
             search: "%#{search.tr(' ', '%').downcase}%").order('events.date_start')
  end

  private

  def end_after_start
    return if date_start.blank? || date_end.blank?
    if date_end < date_start
      errors.add(:date_end, 'ne povas okazi antaŭ la komenca dato')
    end
  end
end
