# == Schema Information
#
# Table name: logs
#
#  id         :bigint           not null, primary key
#  metadata   :jsonb
#  text       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_logs_on_text     (text)
#  index_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Log < ApplicationRecord
  store_accessor :metadata, :event_id, :organization_id

  belongs_to :user

  before_validation :set_default_user

  def event
    Event.find_by(id: event_id)
  end

  def organization
    Organization.find_by(id: organization_id)
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "metadata", "text", "updated_at", "user_id"]
  end

  private

  def set_default_user
    self.user ||= User.system_account if user_id.blank?
  end
end
