# frozen_string_literal: true

# Eventaj rikordoj
class Event < ApplicationRecord

  belongs_to :user

  scope :venontaj, -> { where('date_start >= ?', Date.today) }
  scope :pasintaj, -> { where('date_start < ?', Date.today) }
end
