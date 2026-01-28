# frozen_string_literal: true

# == Schema Information
#
# Table name: followers
#
#  id              :bigint           not null, primary key
#  followable_type :string           not null, indexed => [followable_id]
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  followable_id   :bigint           not null, indexed => [followable_type]
#  user_id         :bigint           indexed
#
class Follower < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true
end
