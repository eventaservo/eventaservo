# frozen_string_literal: true

class ParticipantsController < ApplicationController
  def event
    event = Event.by_code(params[:event_code])

    participant = event.participants.find_by(user_id: current_user.id)
    if participant
      participant.destroy
    else
      event.participants.create!(user: current_user)
    end

    redirect_back fallback_location: root_url
  end
end
