# frozen_string_literal: true

# == Schema Information
#
# Table name: taggings
#
#  id            :bigint           not null, primary key
#  taggable_type :string           not null, uniquely indexed => [tag_id, taggable_id], indexed => [taggable_id]
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tag_id        :bigint           not null, uniquely indexed => [taggable_id, taggable_type], indexed
#  taggable_id   :bigint           not null, uniquely indexed => [tag_id, taggable_type], indexed => [taggable_type]
#
# Foreign Keys
#
#  fk_rails_...  (tag_id => tags.id)
#
class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  validates :tag_id, uniqueness: {scope: [:taggable_id, :taggable_type], message: "tag already associated with this item"}

  after_save :touch_event_category_change, if: -> { taggable_type == "Event" && tag&.category? }
  after_destroy :touch_event_category_change, if: -> { taggable_type == "Event" && tag&.category? }

  private

  # Touch the event so LAST-MODIFIED and SEQUENCE reflect category changes.
  #
  # @return [void]
  def touch_event_category_change
    taggable&.update_column(:updated_at, Time.current)
  end
end
