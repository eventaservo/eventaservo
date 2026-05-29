class AddMetadataColumnToEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :events, :metadata, :jsonb

    # Event.venontaj.where("delayed_job_id IS NOT NULL").each do |event|
    #   event.update_column(:metadata, {event_reminder_job_ids: [event.delayed_job_id]})
    # end

    remove_column :events, :delayed_job_id
  end

  def down
    remove_column :events, :metadata
    add_column :events, :delayed_job_id, :integer
  end
end
