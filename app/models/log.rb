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

  def event
    Event.find_by(id: event_id)
  end

  def organization
    Organization.find_by(id: organization_id)
  end
end
