# frozen_string_literal: true

class BackfillWebcalTokenToUsers < ActiveRecord::Migration[8.1]
  def up
    User.unscoped.where(webcal_token: nil).find_each do |user|
      user.update_column(:webcal_token, user.send(:create_webcal_token))
    end
  end

  def down
  end
end
