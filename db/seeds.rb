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

# Create admin user
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
User.create!(
  name: "EventaServo Sistemo",
  email: "kontakto@eventaservo.org",
  system_account: true,
  password: SecureRandom.hex(16),
  confirmed_at: DateTime.now
)

puts "- Creating organizations"
Organization.create!(
  name: "Universala Esperanto Asocio",
  short_name: "UEA",
  city: "Rotterdam",
  country: Country.find_by(code: "nl"),
  email: "uea@uea.org",
  major: true
)

Organization.create!(
  name: "Tutmonda Esperanta Junulara Organizo",
  short_name: "TEJO",
  city: "Rotterdam",
  country: Country.find_by(code: "nl"),
  email: "info@tejo.org",
  major: true
)

# Fake data only in development (when FactoryBot is available)
if Rails.env.development? && defined?(FactoryBot)
  puts "- Creating sample users and events (development only)"
  2.times do
    user = FactoryBot.create(:user)
    puts "  - User #{user.name}"
    4.times { FactoryBot.create(:event, user:) }
    3.times { FactoryBot.create(:event, :past, user:) }
    3.times { FactoryBot.create(:event, :online, user:) }
  end

  puts "- Creating international calendar events"
  3.times do
    FactoryBot.create(:event, :international_calendar, user: User.all.sample, date_start: DateTime.now + rand(1..3).months)
  end
end

puts "== FINISHED"
