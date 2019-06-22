class AddCityAndRegionToAnalytics < ActiveRecord::Migration[5.2]
  def change
    add_column :analytics, :city, :string
    add_column :analytics, :region, :string
  end
end
