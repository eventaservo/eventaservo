class RemoveDefaultCountryFromUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :country_id, nil
  end
end
