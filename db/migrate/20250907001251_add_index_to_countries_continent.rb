class AddIndexToCountriesContinent < ActiveRecord::Migration[7.2]
  def change
    unless index_exists?(:countries, :continent, name: "index_countries_on_continent")
      add_index :countries, :continent, name: "index_countries_on_continent"
    end
  end
end
