# == Schema Information
#
# Table name: participants
#
#  id         :bigint           not null, primary key
#  public     :boolean          default(FALSE), indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           indexed
#  user_id    :bigint           indexed
#
class Participant < ApplicationRecord
  self.table_name = "participants"

  belongs_to :event, counter_cache: true
  belongs_to :user

  scope :publikaj, -> { where(public: true) }
  scope :ne_publikaj, -> { where(public: false) }
end
