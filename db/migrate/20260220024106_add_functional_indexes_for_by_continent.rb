# frozen_string_literal: true

class AddFunctionalIndexesForByContinent < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Functional index so PostgreSQL can use an index scan for:
    #   immutable_unaccent(lower(countries.continent)) = lower(?)
    # which is used in Event.by_continent and Country.continent_name.
    # Requires the immutable_unaccent() function created in a prior migration.
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_countries_on_unaccent_lower_continent
      ON countries (immutable_unaccent(lower(continent)));
    SQL

    # events.country_id has no index; it is used in every JOIN with countries
    unless index_exists?(:events, :country_id, name: "index_events_on_country_id")
      add_index :events, :country_id, name: "index_events_on_country_id", algorithm: :concurrently
    end
  end

  def down
    execute "DROP INDEX IF EXISTS index_countries_on_unaccent_lower_continent;"
    remove_index :events, name: "index_events_on_country_id", if_exists: true
  end
end
