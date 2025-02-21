# frozen_string_literal: true

class AddParticipantsCounterToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :participants_count, :integer, default: 0
    add_index :events, :participants_count

    # Event.all.find_each { |event| Event.reset_counters(event.id, :participants) }
  end
end
