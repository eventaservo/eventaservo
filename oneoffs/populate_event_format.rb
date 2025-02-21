puts "Starting to populate event format field..."

# Online events (Reta)
online_events = Event.where(online: true, city: "Reta", format: nil)
online_count = online_events.count
puts "Found #{online_count} online events to update"
online_events.each do |event|
  event.update_column(:format, "online")
end

# Onsite events
onsite_events = Event.where(online: false, format: nil)
onsite_count = onsite_events.count
puts "Found #{onsite_count} onsite events to update"
onsite_events.each do |event|
  event.update_column(:format, "onsite")
end

# Hybrid events (online but not Reta)
hybrid_events = Event.where(online: true).where.not(city: "Reta").where(format: nil)
hybrid_count = hybrid_events.count
puts "Found #{hybrid_count} hybrid events to update"
hybrid_events.each do |event|
  event.update_column(:format, "hybrid")
end

total = online_count + onsite_count + hybrid_count
puts "\nUpdate completed. Modified #{total} events:"
puts "- #{online_count} online events"
puts "- #{onsite_count} onsite events"
puts "- #{hybrid_count} hybrid events"
