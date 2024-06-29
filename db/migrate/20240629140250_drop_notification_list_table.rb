class DropNotificationListTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :notification_lists
  end
end
