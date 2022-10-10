class CreateJwtTokenForUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :jwt_token, :string

    User.unscoped.all.each do |user|
      payload = { id: user.id }
      jwt_token = JWT.encode(payload, Rails.application.credentials.dig(:jwt, :secret), 'HS256')
      user.update_columns(jwt_token: jwt_token)
    end
  end

  def down
    remove_column :users, :jwt_token
  end
end
