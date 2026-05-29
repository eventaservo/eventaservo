class CreateFollowers < ActiveRecord::Migration[5.2]
  def change
    create_table :followers do |t|
      t.references :followable, polymorphic: true, index: true, null: false
      t.references :user

      t.timestamps
    end
  end
end
