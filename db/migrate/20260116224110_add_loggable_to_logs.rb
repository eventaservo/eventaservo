# frozen_string_literal: true

class AddLoggableToLogs < ActiveRecord::Migration[7.2]
  def change
    add_reference :logs, :loggable, polymorphic: true, null: true, index: true
    change_column_null :logs, :user_id, true
  end
end
