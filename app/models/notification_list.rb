# frozen_string_literal: true

class NotificationList < ApplicationRecord
  include Code

  belongs_to :country, inverse_of: :recipients

  validates_presence_of :code, :email, :country_id
  validates_uniqueness_of :email, scope: :country_id
end
