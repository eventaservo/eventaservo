class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.integer :event_id, null: false
      t.string :url, null: false
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
