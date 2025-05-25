class RemovesActAsTaggableOnTables < ActiveRecord::Migration[7.2]
  def change
    drop_table :taggings
    drop_table :tags
  end
end
