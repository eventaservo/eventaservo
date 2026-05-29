# This migration comes from acts_as_taggable_on_engine (originally 3)
class AddTaggingsCounterCacheToTags < ActiveRecord::Migration[5.2]
  def up
    add_column :tags, :taggings_count, :integer, default: 0
  end

  def down
    remove_column :tags, :taggings_count
  end
end
