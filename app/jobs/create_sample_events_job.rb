# frozen_string_literal: true

class CreateSampleEventsJob < ApplicationJob
  def perform(user_id)
    return false if Rails.env.production?

    user = User.find_by(id: user_id)
    return false unless user&.admin?

    countries = Country.all.to_a

    # Create 20 future events
    20.times do
      create_event(
        user: user,
        countries: countries,
        date_start: DateTime.now + rand(1..90).days + rand(8..12).hours
      )
    end

    # Create 5 past events
    5.times do
      create_event(
        user: user,
        countries: countries,
        date_start: DateTime.now - rand(2..90).days
      )
    end
  end

  private

  def create_event(user:, countries:, date_start:)
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
    event
  end
end
