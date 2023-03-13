# == Schema Information
#
# Table name: participants
#
#  id         :bigint           not null, primary key
#  public     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_participants_on_event_id  (event_id)
#  index_participants_on_public    (public)
#  index_participants_on_user_id   (user_id)
#
class Participant < ApplicationRecord
  self.table_name = "participants"

  belongs_to :event, counter_cache: true
  belongs_to :user

  scope :publikaj, -> { where(public: true) }
  scope :ne_publikaj, -> { where(public: false) }
end
