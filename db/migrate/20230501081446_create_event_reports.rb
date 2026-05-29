class CreateEventReports < ActiveRecord::Migration[7.0]
  def change
    create_table :event_reports do |t|
      t.references :event, null: false
      t.string :title
      t.string :url, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
