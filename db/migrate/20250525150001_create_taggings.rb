class CreateTaggings < ActiveRecord::Migration[7.0]
  def change
    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], unique: true, name: 'index_taggings_on_tag_and_taggable'
  end
end
