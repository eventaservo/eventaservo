puts "Starting removal of 'Loka' from specolisto..."

events = Event.where("specolisto ILIKE '%loka%'")
count = events.count

puts "Found #{count} events to update"

events.each do |event|
  old_value = event.specolisto

  # Remove "Loka" and handle comma cleanup
  new_value = old_value
    .split(",")
    .map(&:strip)
    .reject { |word| word.downcase == "loka" }
    .join(", ")

  event.update_column(:specolisto, new_value)
  puts "Updated event #{event.id}: '#{old_value}' -> '#{new_value}'"
end

puts "\nUpdate completed. Modified #{count} events."
