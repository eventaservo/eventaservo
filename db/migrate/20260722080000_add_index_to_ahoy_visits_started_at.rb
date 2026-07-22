# frozen_string_literal: true

class AddIndexToAhoyVisitsStartedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :ahoy_visits, :started_at
  end
end
