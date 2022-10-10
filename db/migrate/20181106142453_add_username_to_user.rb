class AddUsernameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :username, :string

    User.all.unscoped.each do |user|
      user.generate_username
    end
  end
end
