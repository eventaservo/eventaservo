# frozen_string_literal: true

# Execute with: rails runner oneoffs/migrate_specolisto_to_tags.rb

puts "Starting migration from specolisto to tags..."
total = Event.count
migrated = 0
errors = 0
tag_cache = {}

Tag.find_or_initialize_by(name: "Kunveno/Evento").tap do |tag|
  tag.group_name = "category"
  tag.sort_order = 100
  tag.display_in_filters = true
  tag.save!
end
Tag.find_or_initialize_by(name: "Kurso").tap do |tag|
  tag.group_name = "category"
  tag.sort_order = 200
  tag.display_in_filters = true
  tag.save!
end
Tag.find_or_initialize_by(name: "Alia").tap do |tag|
  tag.group_name = "category"
  tag.sort_order = 300
  tag.display_in_filters = true
  tag.save!
end

Tag.find_or_initialize_by(name: "Anonco").tap do |tag|
  tag.group_name = "characteristic"
  tag.sort_order = 100
  tag.display_in_filters = false
  tag.save!
end
Tag.find_or_initialize_by(name: "Konkurso").tap do |tag|
  tag.group_name = "characteristic"
  tag.sort_order = 200
  tag.display_in_filters = false
  tag.save!
end
Tag.find_or_initialize_by(name: "Por junuloj").tap do |tag|
  tag.group_name = "characteristic"
  tag.sort_order = 300
  tag.display_in_filters = true
  tag.save!
end

Tag.find_or_initialize_by(name: "Unutaga").tap do |tag|
  tag.group_name = "time"
  tag.sort_order = 100
  tag.display_in_filters = true
  tag.save!
end
Tag.find_or_initialize_by(name: "Plurtaga").tap do |tag|
  tag.group_name = "time"
  tag.sort_order = 200
  tag.display_in_filters = true
  tag.save!
end

Event.all.find_each do |event|
  print "Processing event ID ##{event.id}...      \r"

  tags = event.specolisto.tr(" ", "").split(",")
  tags.each do |tag_name|
    group_name =
      if tag_name == "Anonco" || tag_name == "Konkurso"
        :characteristic
      else
        :category
      end
    tag_cache[[tag_name, group_name]] ||= Tag.find_or_create_by!(name: tag_name, group_name: group_name)
    tag = tag_cache[[tag_name, group_name]]
    unless event.tags.include?(tag)
      event.tags << tag
    end
  rescue => e
    puts "Error migrating event ##{event.id} (tag: #{tag_name}): #{e.class} - #{e.message}"
    errors += 1
  end

  event.send(:update_duration_tags)

  migrated += 1
  puts "Migrated #{migrated} of #{total} events" if migrated % 100 == 0
end
puts "\nMigration completed. Events processed: #{migrated}, errors: #{errors}, total: #{total}"
