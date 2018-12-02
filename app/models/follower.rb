# frozen_string_literal: true

class Follower < ApplicationRecord
  belongs_to :user
end
