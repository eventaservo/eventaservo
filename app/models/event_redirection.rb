# == Schema Information
#
# Table name: event_redirections
#
#  id            :bigint           not null, primary key
#  hits          :integer          default(0), not null
#  new_short_url :string           not null
#  old_short_url :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_event_redirections_on_old_short_url  (old_short_url) UNIQUE
#
class EventRedirection < ApplicationRecord
  validates_presence_of :old_short_url, :new_short_url

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "hits", "id", "new_short_url", "old_short_url", "updated_at"]
  end
end
