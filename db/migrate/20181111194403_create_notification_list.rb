class CreateNotificationList < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_lists do |t|
      t.integer :country_id, null: false
      t.string :email, null: false
      t.string :code, null: false

      t.timestamps
    end
    add_index :notification_lists, [:country_id, :email]
    add_index :notification_lists, :code
  end
end
