class AddSystemAccoutToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :system_account, :bool, default: false

    User.find_by(email: "kontakto@eventaservo.org")&.update(system_account: true)
  end
end
