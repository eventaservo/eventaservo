# frozen_string_literal: true

class CreateSampleEventsJob < ApplicationJob
  def perform(user_id)
    return false if Rails.env.production?

    user = User.find_by(id: user_id)
    return false unless user&.admin?

    FactoryBot.create_list(:event, 20, :future, user: user)
    FactoryBot.create_list(:event, 5, :past, user: user)
  end
end
