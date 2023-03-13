# frozen_string_literal: true

# == Schema Information
#
# Table name: ads
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint
#
# Indexes
#
#  index_ads_on_event_id  (event_id)
#
class Ad < ApplicationRecord
  has_one_attached :image

  validates :url, presence: true
  validates :image, presence: true

  scope :active, -> { where(active: true) }
end
