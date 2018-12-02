# frozen_string_literal: true

class Participant < ApplicationRecord
  belongs_to :event
  belongs_to :user
end
