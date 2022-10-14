class AddUrlToAds < ActiveRecord::Migration[6.1]
  def change
    add_column :ads, :url, :string
  end
end
