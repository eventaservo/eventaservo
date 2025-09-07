class CreateEventRecurrences < ActiveRecord::Migration[7.2]
  def change
    create_table :event_recurrences do |t|
      t.references :master_event, null: false, foreign_key: {to_table: :events}
      t.string :frequency, null: false # daily, weekly, monthly
      t.integer :interval, default: 1, null: false
      t.text :days_of_week # Serialized array for days of week (0=sunday, 6=saturday)
      t.integer :day_of_month # For monthly recurrence (1-31)
      t.string :end_type, null: false # never, after_count, on_date
      t.date :end_date
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Add fields for event hierarchy
    add_column :events, :master_event_id, :bigint
    add_column :events, :is_recurring_master, :boolean, default: false, null: false

    # Performance indexes
    add_index :events, :master_event_id
    add_index :events, :is_recurring_master
    add_index :events, [:is_recurring_master, :date_start]
    add_index :events, [:master_event_id, :date_start]
    add_index :event_recurrences, [:active, :frequency]
    add_index :event_recurrences, [:master_event_id, :active]

    # Foreign key for event hierarchy
    add_foreign_key :events, :events, column: :master_event_id
  end
end
