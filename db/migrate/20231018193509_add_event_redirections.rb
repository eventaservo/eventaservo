class AddEventRedirections < ActiveRecord::Migration[7.0]
  def change
    create_table :event_redirections do |t|
      t.string :old_short_url, null: false
      t.string :new_short_url, null: false
      t.integer :hits, null: false, default: 0

      t.timestamps
    end

    add_index :event_redirections, :old_short_url, unique: true
  end
end
