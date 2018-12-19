# frozen_string_literal: true

class NotificationList < ApplicationRecord
  include Code

  belongs_to :country, inverse_of: :recipients

  validates :code, :email, :country_id, presence: true
  validates :email, uniqueness: { scope: :country_id }

  scope :admins, -> { where(email: 'shayani@gmail.com') }
end
