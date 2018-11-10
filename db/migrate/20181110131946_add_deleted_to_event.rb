class AddDeletedToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :deleted, :boolean, default: false, null: false
    add_index :events, :deleted
  end
end
