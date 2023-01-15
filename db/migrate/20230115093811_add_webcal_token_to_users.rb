class AddWebcalTokenToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :webcal_token, :string, unique: true

    User.unscoped.all.each(&:regenerate_webcal_token!)
  end

  def down
    remove_column :users, :webcal_token
  end
end
