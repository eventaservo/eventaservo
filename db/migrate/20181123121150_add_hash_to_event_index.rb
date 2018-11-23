class AddHashToEventIndex < ActiveRecord::Migration[5.2]
  def up
    execute "DROP INDEX index_events_on_content;"
    execute "CREATE INDEX index_events_on_content ON events(md5(content));"
  end

  def down
    execute "DROP INDEX index_events_on_content;"
    add_index :events, :content
  end
end
