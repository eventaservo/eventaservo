# frozen_string_literal: true

class UpdateUtcTimezoneDisplay < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE timezones SET eo = 'UTC' WHERE en = 'Etc/UTC'"
  end

  def down
    execute "UPDATE timezones SET eo = 'Etc/UTC' WHERE en = 'Etc/UTC'"
  end
end
