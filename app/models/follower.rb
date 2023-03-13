# frozen_string_literal: true

# == Schema Information
#
# Table name: followers
#
#  id              :bigint           not null, primary key
#  followable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  followable_id   :bigint           not null
#  user_id         :bigint
#
# Indexes
#
#  index_followers_on_followable_type_and_followable_id  (followable_type,followable_id)
#  index_followers_on_user_id                            (user_id)
#
class Follower < ApplicationRecord
  belongs_to :user
end
