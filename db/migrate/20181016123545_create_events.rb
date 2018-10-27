class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :description, limit: 400
      t.text :content
      t.string :address
      t.text :city
      t.integer :country_id, null: false
      t.integer :user_id, null: false
      t.datetime :date_start, null: false
      t.datetime :date_end
      t.string :code, null: false

      t.timestamps
    end
    add_index :events, :title
    add_index :events, :description
    add_index :events, :content
    add_index :events, :address
    add_index :events, :city
    add_index :events, :user_id
    add_index :events, :date_start
    add_index :events, :date_end
  end
end
