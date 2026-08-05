# frozen_string_literal: true

class AddIndexToEventsCoordinates < ActiveRecord::Migration[8.1]
  def change
    add_index :events, [:latitude, :longitude]
  end
end
