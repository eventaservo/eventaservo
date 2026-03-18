# frozen_string_literal: true

class AddIndexToEventsUpdatedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :events, :updated_at
  end
end
