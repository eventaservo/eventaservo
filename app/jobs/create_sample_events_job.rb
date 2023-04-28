# frozen_string_literal: true

class CreateSampleEventsJob < ApplicationJob
  def perform(user_id)
    return false if Rails.env.production?

    user = User.find_by(id: user_id)
    return false unless user&.admin?

    FactoryBot.create_list(:event, 5, :venonta, user: user)
    FactoryBot.create_list(:event, 2, :past, user: user)
  end
end
