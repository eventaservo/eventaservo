class AddMailingsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mailings, :jsonb
  end
end
