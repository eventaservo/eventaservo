# frozen_string_literal: true

# Eventaj rikordoj
class Event < ApplicationRecord

  before_validation :set_code

  belongs_to :user
  belongs_to :country
  has_many :attachments, as: :attachable, dependent: :destroy

  validates_presence_of :title, :description, :city, :country_id, :date_start, :date_end, :code
  validates_uniqueness_of :code

  scope :venontaj, -> { where('date_start >= ?', Date.today) }
  scope :pasintaj, -> { where('date_start < ?', Date.today) }
  scope :by_country_id, ->(id) { where(country_id: id) }
  scope :by_city, ->(city) { where(city: city) }

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
    self.code = SecureRandom.urlsafe_base64(8)
  end
end
