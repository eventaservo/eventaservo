# frozen_string_literal: true

class DropActiveAdminComments < ActiveRecord::Migration[8.1]
  def change
    drop_table :active_admin_comments, if_exists: true
  end
end
