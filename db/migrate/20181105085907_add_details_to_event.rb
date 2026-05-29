class AddDetailsToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :site, :string
    add_column :events, :email, :string
  end
end
