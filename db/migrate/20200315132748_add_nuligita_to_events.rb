class AddNuligitaToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :cancelled, :boolean, default: false
    add_index :events, :cancelled
    add_column :events, :cancel_reason, :text
  end
end
