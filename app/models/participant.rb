class Participant < ApplicationRecord
  self.table_name = 'participants'

  belongs_to :event, counter_cache: true
  belongs_to :user

  scope :publikaj, -> { where(public: true) }
  scope :ne_publikaj, -> { where(public: false) }
end
