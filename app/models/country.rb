class Country < ApplicationRecord

  has_many :users, inverse_of: :country
  has_many :recipients, class_name: 'NotificationList'

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope { order(:name) }
end
