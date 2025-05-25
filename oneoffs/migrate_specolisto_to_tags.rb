# frozen_string_literal: true

# Execute with: rails runner oneoffs/migrate_specolisto_to_tags.rb

puts 'Starting migration from specolisto to tags...'
total = Event.count
migrated = 0
errors = 0
tag_cache = {}

Event.find_each do |event|
  print "Processing event ID ##{event.id}...      \r"
  next if event.specolisto.blank?
  next if event.tags.any?

  tags = event.specolisto.tr(' ', '').split(',')
  tags.each do |tag_name|
    group_name = :category
    tag_cache[[tag_name, group_name]] ||= Tag.find_or_create_by!(name: tag_name, group_name: group_name)
    tag = tag_cache[[tag_name, group_name]]
    unless event.tags.include?(tag)
      event.tags << tag
    end
  rescue => e
    puts "Error migrating event ##{event.id} (tag: #{tag_name}): #{e.class} - #{e.message}"
    errors += 1
  end
  migrated += 1
  puts "Migrated #{migrated} of #{total} events" if migrated % 100 == 0
end
puts "\nMigration completed. Events processed: #{migrated}, errors: #{errors}, total: #{total}"
