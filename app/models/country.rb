# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :users, inverse_of: :country
  has_many :recipients, class_name: 'NotificationList', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :continent, presence: true

  default_scope { order(:name) }

  scope :not_online, -> { where.not(name: 'Online') }
end
