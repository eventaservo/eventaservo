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
User.create(email: "admin@eventaservo.org",
            name: "Administranto",
            password: "administranto",
            username: "admin",
            country_id: Country.find_by(code: "br").id,
            city: "Rio de Janeiro",
            admin: true,
            confirmed_at: DateTime.now)

puts "Create System Account"
FactoryBot.create(:user, name: "EventaServo Sistemo", email: "kontakto@eventaservo.org", system_account: true)

# Events
puts "- Creating events"
4.times { FactoryBot.create(:event) }
4.times { FactoryBot.create(:event, user: User.system_account) }
3.times { FactoryBot.create(:event, :online) }
3.times { FactoryBot.create(:event, :past) }
puts "- Creating international calendar events"
3.times { FactoryBot.create(:event, :international_calendar, date_start: DateTime.now + rand(1..3).months) }

# Ads
puts "- Creating ads"
5.times { FactoryBot.create(:ad) }

puts "== FINISHED"
