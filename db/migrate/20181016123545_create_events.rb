class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :address
      t.text :city
      t.integer :country_id
      t.integer :user_id
      t.datetime :date_start
      t.datetime :date_end
      t.string :code, null: false

      t.timestamps
    end
    add_index :events, :title
    add_index :events, :description
    add_index :events, :address
    add_index :events, :city
    add_index :events, :user_id
    add_index :events, :date_start
    add_index :events, :date_end
  end
end
