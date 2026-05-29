class AddDisabledToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :disabled, :bool, default: false
    add_index :users, :disabled
  end
end
