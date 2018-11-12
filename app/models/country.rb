class Country < ApplicationRecord

  has_many :users, inverse_of: :country
  has_many :recipients, class_name: 'NotificationList'

  default_scope { order(:name) }
end
