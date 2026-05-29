class ShangasUzantanDefaultanLandon < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :country_id, 99999
  end
end
