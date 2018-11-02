class Country < ApplicationRecord

  has_many :users, inverse_of: :country

  default_scope { order(:name) }
end
