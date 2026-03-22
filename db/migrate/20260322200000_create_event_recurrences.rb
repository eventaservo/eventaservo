# frozen_string_literal: true

# Creates the event_recurrences table for recurring event rules
# and adds recurrent_master_event_id to events for parent-child linking.
class CreateEventRecurrences < ActiveRecord::Migration[8.0]
  def change
    create_table :event_recurrences do |t|
      t.references :master_event, null: false, foreign_key: {to_table: :events}, index: {unique: true}
      t.string :frequency, null: false
      t.integer :interval, default: 1, null: false
      t.integer :days_of_week, array: true, default: []
      t.integer :day_of_month
      t.integer :week_of_month
      t.integer :day_of_week_monthly
      t.integer :month_of_year
      t.string :end_type, null: false, default: "never"
      t.date :end_date
      t.boolean :active, default: true, null: false
      t.date :last_generated_date

      t.timestamps
    end

    add_index :event_recurrences, [:active, :frequency]

    add_column :events, :recurrent_master_event_id, :bigint
    add_index :events, :recurrent_master_event_id
    add_foreign_key :events, :events, column: :recurrent_master_event_id
  end
end
