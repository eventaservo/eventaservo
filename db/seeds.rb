# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "== Running seeds.rb file"

puts "- Loading Fixtures"
Rake.application["db:fixtures:load"].invoke

# Kreas la administranton
User.destroy_all
User.create(
  email: "admin@eventaservo.org",
  name: "Administranto",
  password: "administranto",
  username: "admin",
  country_id: Country.find_by(code: "br").id,
  city: "Rio de Janeiro",
  admin: true,
  confirmed_at: DateTime.now
)

puts "Create System Account"
FactoryBot.create(:user, name: "EventaServo Sistemo", email: "kontakto@eventaservo.org", system_account: true)

puts "- Creating organizations"
FactoryBot.create(:organization, :uea)
FactoryBot.create(:organization, :tejo)
3.times { FactoryBot.create(:organization) }

# Common users
puts "- Creating users and events"
2.times do
  user = FactoryBot.create(:user)
  puts "  - User #{user.name}"
  4.times do
    puts "  \\_ creating future event"
    FactoryBot.create(:event, user:)
  end
  3.times do
    puts "  \\_ creating past event"
    FactoryBot.create(:event, :past, user:)
  end
  3.times do
    puts "  \\_ creating future online event"
    FactoryBot.create(:event, :online, user:)
  end
end

# International events
puts "- Creating international calendar events"
3.times do
  FactoryBot.create(
    :event,
    :international_calendar,
    user: User.all.sample,
    date_start: DateTime.now + rand(1..3).months
  )
end

puts "== FINISHED"
