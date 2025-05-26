# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id                 :bigint           not null, primary key
#  display_in_filters :boolean          default(TRUE), not null
#  group_name         :string           not null, indexed => [name]
#  name               :string           not null, indexed => [group_name]
#  sort_order         :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  validates :name, presence: true
  validates :group_name, presence: true
  validates :name, uniqueness: {scope: :group_name, message: "should be unique within its group"}

  enum :group_name, {
    category: "category",
    characteristic: "characteristic",
    time: "time"
  }

  scope :categories, -> { where(group_name: "category") }
  scope :characteristics, -> { where(group_name: "characteristic") }
  scope :times, -> { where(group_name: "time") }

  def self.ransackable_attributes(auth_object = nil)
    ["group_name", "name", "sort_order", "display_in_filters"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["taggings"]
  end
end
