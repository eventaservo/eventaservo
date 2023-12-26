# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_lists
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :integer          not null
#
# Indexes
#
#  index_notification_lists_on_code                  (code)
#  index_notification_lists_on_country_id_and_email  (country_id,email)
#
class NotificationList < ApplicationRecord
  include Code

  belongs_to :country, inverse_of: :recipients

  validates :code, :email, :country_id, presence: true
  validates :email, uniqueness: {scope: :country_id}
end
