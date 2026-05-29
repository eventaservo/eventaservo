# frozen_string_literal: true

class AddUniqueIndexToParticipants < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/MethodLength
  def up
    deduplicate_participants
    reset_participants_count
    add_index :participants, [:event_id, :user_id], unique: true,
      name: "index_participants_on_event_id_and_user_id"
  end
  # rubocop:enable Metrics/MethodLength

  def down
    remove_index :participants, name: "index_participants_on_event_id_and_user_id"
  end

  private

  # Removes duplicate participant records, keeping only the most recent
  # record for each (event_id, user_id) pair.
  #
  # This is necessary because Participant has never enforced uniqueness
  # at the application or database level, so production data may contain
  # duplicates that would cause the unique index creation to fail.
  #
  # @return [void]
  def deduplicate_participants
    execute(<<~SQL.squish)
      DELETE FROM participants
      WHERE id NOT IN (
        SELECT DISTINCT ON (event_id, user_id) id
        FROM participants
        ORDER BY event_id, user_id, id DESC
      )
    SQL
  end

  # Resets the participants_count counter cache for all events after
  # the raw SQL DELETE, which bypasses ActiveRecord callbacks.
  #
  # @return [void]
  def reset_participants_count
    execute(<<~SQL.squish)
      UPDATE events
      SET participants_count = (
        SELECT COUNT(*) FROM participants
        WHERE participants.event_id = events.id
      )
    SQL
  end
end
