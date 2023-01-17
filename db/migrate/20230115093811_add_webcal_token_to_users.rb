class AddWebcalTokenToUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :webcal_token, :string, unique: true

    User.unscoped.all.each(&:generate_webcal_token!)
  end

  def down
    remove_column :users, :webcal_token
  end
end
