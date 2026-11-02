# frozen_string_literal: true

# Adds a composite index on +events(latitude, longitude)+ to support
# bounding-box lookups in {Events::NearbyCitiesQuery}.
class AddIndexToEventsCoordinates < ActiveRecord::Migration[8.0]
  # Applies the migration.
  #
  # @return [void]
  def change
    add_index :events, [:latitude, :longitude]
  end
end
