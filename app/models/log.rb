# frozen_string_literal: true

# == Schema Information
#
# Table name: logs
#
#  id            :bigint           not null, primary key
#  loggable_type :string           indexed => [loggable_id]
#  metadata      :jsonb
#  text          :string           indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  loggable_id   :bigint           indexed => [loggable_type]
#  user_id       :bigint           indexed
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Log < ApplicationRecord
  store_accessor :metadata, :event_id, :organization_id

  belongs_to :user, optional: true
  belongs_to :loggable, polymorphic: true, optional: true

  before_validation :set_default_user, if: -> { user_id.blank? && loggable.blank? }

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
    self.user ||= User.system_account
  end
end
