# frozen_string_literal: true

class Ad < ApplicationRecord
  has_one_attached :image

  validates :url, presence: true
  validates :image, presence: true
end
