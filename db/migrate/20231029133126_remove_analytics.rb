class RemoveAnalytics < ActiveRecord::Migration[7.0]
  def change
    drop_table :analytics
  end
end
