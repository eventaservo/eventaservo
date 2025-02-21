class RenameInternaciaCategoryOnAllRecords < ActiveRecord::Migration[7.2]
  def up
    puts "Starting specolisto update..."

    events = Event.where("specolisto ILIKE '%internacia%'")
    count = events.count

    puts "Found #{count} events to update"

    events.each do |event|
      old_value = event.specolisto
      new_value = event.specolisto.gsub("Internacia", "Kunveno/Evento")

      event.update_column(:specolisto, new_value)
      puts "Updated event #{event.id}: '#{old_value}' -> '#{new_value}'"
    end

    puts "\nUpdate completed. Modified #{count} events."
  end

  def down
    # no-op
  end
end
