# frozen_string_literal: true

# Eventaj rikordoj
class Event < ApplicationRecord

  belongs_to :user

  validates_presence_of :title, :description, :city, :country_id, :date_start, :date_end

  scope :venontaj, -> { where('date_start >= ?', Date.today) }
  scope :pasintaj, -> { where('date_start < ?', Date.today) }
end
