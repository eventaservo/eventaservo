class AddTimeZoneToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :time_zone, :string, null: false, default: 'Etc/UTC'
  end
end
