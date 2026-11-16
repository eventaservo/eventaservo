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
  confirmed_at: DateTime.now,
  country: Country.find_by(code: "br")
)

puts "- Creating organizations"
uea = Organization.create!(
  name: "Universala Esperanto Asocio",
  short_name: "UEA",
  city: "Rotterdam",
  country: Country.find_by(code: "nl"),
  email: "uea@uea.org",
  url: "https://uea.org",
  youtube: "https://www.youtube.com/user/UEAviva",
  description: "Universala Esperanto-Asocio estis fondita en 1908 kiel organizaĵo de individuaj esperantistoj. Nuntempe UEA estas la plej granda internacia organizaĵo por la parolantoj de Esperanto kaj havas membrojn en 120 landoj.",
  major: true
)

tejo = Organization.create!(
  name: "Tutmonda Esperanta Junulara Organizo",
  short_name: "TEJO",
  city: "Rotterdam",
  country: Country.find_by(code: "nl"),
  email: "info@tejo.org",
  url: "https://www.tejo.org",
  description: "Tutmonda Esperantista Junulara Organizo (TEJO) estas organizo de junaj parolantoj de Esperanto kun individuaj membroj kaj landaj sekcioj en ĉirkaŭ 40 landoj. TEJO mem estas la junulara sekcio de Universala Esperanto-Asocio. Ĉefa sidejo troviĝas en Roterdamo, Nederlando.",
  major: true
)

puts "- Attaching organization logos"
seed_logos = {
  "UEA" => Rails.root.join("app/assets/images/uea_emblemeto.png"),
  "TEJO" => Rails.root.join("app/assets/images/tejo.png"),
  "ILEI" => Rails.root.join("app/assets/images/ilei.png"),
  "SAT" => Rails.root.join("db/seeds/logos/sat.png"),
  "rotterdam_centre" => Rails.root.join("db/seeds/logos/rotterdam_centre.png"),
  "sao_paulo_klubo" => Rails.root.join("db/seeds/logos/sao_paulo_klubo.png"),
  "tokyo_society" => Rails.root.join("db/seeds/logos/tokyo_society.png")
}

seed_logos.each do |short_name, logo_path|
  organization = Organization.find_by(short_name: short_name)
  next unless organization && File.exist?(logo_path)

  File.open(logo_path, "rb") do |file|
    organization.logo.attach(
      io: file,
      filename: File.basename(logo_path),
      content_type: "image/png"
    )
  end
end
_unused = [uea, tejo]

# Sample data for development environment
if Rails.env.development?
  puts "- Creating sample users and events (development only)"

  countries = Country.all.to_a

  2.times do |i|
    user = User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: "password123",
      city: Faker::Address.city,
      country: countries.sample,
      confirmed_at: DateTime.now
    )
    puts "  - User #{user.name}"

    # Future events
    4.times do
      date_start = DateTime.now + rand(1..30).days + rand(8..12).hours
      event = Event.new(
        title: Faker::Book.title,
        description: "Evento por praktiki Esperanton kun amikoj.",
        content: Faker::Lorem.paragraph(sentence_count: 10),
        user: user,
        address: Faker::Address.street_address,
        city: Faker::Address.city,
        country: countries.sample,
        date_start: date_start,
        date_end: date_start + rand(2..6).hours,
        email: Faker::Internet.email,
        code: SecureRandom.urlsafe_base64(12),
        time_zone: "America/Sao_Paulo",
        online: false,
        format: "onsite"
      )
      event.instance_variable_set(:@created_from_factory, true)
      event.save!
      event.tags << Tag.categories.first if Tag.categories.any?
    end

    # Past events
    3.times do
      date_start = DateTime.now - rand(2..90).days
      event = Event.new(
        title: Faker::Book.title,
        description: "Evento pasinta.",
        content: Faker::Lorem.paragraph(sentence_count: 10),
        user: user,
        address: Faker::Address.street_address,
        city: Faker::Address.city,
        country: countries.sample,
        date_start: date_start,
        date_end: date_start + rand(2..6).hours,
        email: Faker::Internet.email,
        code: SecureRandom.urlsafe_base64(12),
        time_zone: "America/Sao_Paulo",
        online: false,
        format: "onsite"
      )
      event.instance_variable_set(:@created_from_factory, true)
      event.save!
      event.tags << Tag.categories.first if Tag.categories.any?
    end

    # Online events
    3.times do
      date_start = DateTime.now + rand(1..30).days + rand(8..12).hours
      event = Event.new(
        title: Faker::Book.title,
        description: "Reta evento.",
        content: Faker::Lorem.paragraph(sentence_count: 10),
        user: user,
        city: "Reta",
        country_id: 99999,
        date_start: date_start,
        date_end: date_start + rand(2..6).hours,
        email: Faker::Internet.email,
        code: SecureRandom.urlsafe_base64(12),
        time_zone: "Etc/UTC",
        online: true,
        format: "online"
      )
      event.instance_variable_set(:@created_from_factory, true)
      event.save!
      event.tags << Tag.categories.first if Tag.categories.any?
    end
  end

  puts "- Creating international calendar events"
  3.times do
    date_start = DateTime.now + rand(1..3).months
    event = Event.new(
      title: Faker::Book.title,
      description: "Internacia evento.",
      content: Faker::Lorem.paragraph(sentence_count: 10),
      user: User.all.sample,
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      country: countries.sample,
      date_start: date_start,
      date_end: date_start + rand(2..6).hours,
      email: Faker::Internet.email,
      code: SecureRandom.urlsafe_base64(12),
      time_zone: "Etc/UTC",
      international_calendar: true,
      online: false,
      format: "onsite"
    )
    event.instance_variable_set(:@created_from_factory, true)
    event.save!
    event.tags << Tag.categories.first if Tag.categories.any?
  end
end

puts "== FINISHED"
