class AddCityAndCountryToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :city, :string, index: true
    add_column :users, :country_id, :integer, index: true
  end
end
