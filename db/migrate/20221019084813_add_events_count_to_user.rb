class AddEventsCountToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :events_count, :integer, default: 0
    add_index :users, :events_count

    User.all.find_each { |user| User.reset_counters(user.id, :events) }
  end
end
