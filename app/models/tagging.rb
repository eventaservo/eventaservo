# frozen_string_literal: true

# == Schema Information
#
# Table name: taggings
#
#  id            :bigint           not null, primary key
#  taggable_type :string           not null, indexed => [tag_id, taggable_id], indexed => [taggable_id]
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tag_id        :bigint           not null, indexed => [taggable_id, taggable_type], indexed
#  taggable_id   :bigint           not null, indexed => [tag_id, taggable_type], indexed => [taggable_type]
#
# Foreign Keys
#
#  fk_rails_...  (tag_id => tags.id)
#
class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  validates :tag_id, uniqueness: {scope: [:taggable_id, :taggable_type], message: "tag already associated with this item"}
end
