class DropTableAdminUsers < ActiveRecord::Migration[6.1]
  def change
    drop_table :admin_users
  end
end
