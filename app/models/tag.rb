# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  group_name :string           not null, indexed => [name]
#  name       :string           not null, indexed => [group_name]
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  validates :name, presence: true
  validates :group_name, presence: true
  validates :name, uniqueness: { scope: :group_name, message: "should be unique within its group" }

  scope :categories, -> { where(group_name: "category") }
  scope :characteristics, -> { where(group_name: "characteristic") }
end
