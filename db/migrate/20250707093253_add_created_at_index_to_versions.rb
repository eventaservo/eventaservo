class AddCreatedAtIndexToVersions < ActiveRecord::Migration[7.2]
  def change
    add_index :versions, :created_at
  end
end
