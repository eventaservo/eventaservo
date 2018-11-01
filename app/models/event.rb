# frozen_string_literal: true

# Eventaj dateno
class Event < ApplicationRecord

  after_initialize :set_code, if: :new_record?
  after_update :send_updates_to_followers

  belongs_to :user
  belongs_to :country
  has_many :participants, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :followers, as: :followable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates_presence_of :title, :description, :city, :country_id, :date_start, :date_end, :code
  validates_uniqueness_of :code

  scope :venontaj, -> { where('date_start >= ?', Date.today) }
  scope :pasintaj, -> { where('date_start < ?', Date.today) }
  scope :by_country_id, ->(id) { where(country_id: id) }
  scope :by_city, ->(city) { where(city: city) }
  scope :by_user, ->(user) { where(user: user) }

  def self.grouped_by_months
    order(:date_start).group_by { |m| m.date_start.beginning_of_month }
  end

  def self.count_by_country
    joins(:country).select('countries.name', 'count(events.id)').group('countries.name').order('countries.name')
  end

  def self.count_by_cities
    select('city as name', 'count(id)').group(:city).order(:city)
  end

  private

  def set_code
    self.code = SecureRandom.urlsafe_base64(12)
  end

  def send_updates_to_followers
    return false
    EventMailer.send_updates_to_followers(self).deliver unless self.followers.empty?
  end
end
