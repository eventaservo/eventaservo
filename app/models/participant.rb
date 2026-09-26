# frozen_string_literal: true

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

  # Returns participants who agreed to have their name shown publicly.
  #
  # @return [ActiveRecord::Relation<Participant>] participants with +public+ set to true
  scope :publicly_listed, -> { where(public: true) }

  # Returns participants who did not agree to have their name shown publicly.
  #
  # @return [ActiveRecord::Relation<Participant>] participants with +public+ set to false
  scope :not_publicly_listed, -> { where(public: false) }
end
