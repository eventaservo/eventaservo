# frozen_string_literal: true

class CreateSampleEventsJob < ApplicationJob
  def perform(user_id)
    return false if Rails.env.production?
    return false unless defined?(FactoryBot)

    user = User.find_by(id: user_id)
    return false unless user&.admin?

    FactoryBot.create_list(:event, 20, :future, user:)
    FactoryBot.create_list(:event, 5, :past, user:)
  end
end
