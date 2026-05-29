# frozen_string_literal: true

class AddUniqueIndexToParticipants < ActiveRecord::Migration[7.1]
  def change
    add_index :participants, [:event_id, :user_id], unique: true,
              name: "index_participants_on_event_id_and_user_id"
  end
end
