# frozen_string_literal: true

class ParticipantsController < ApplicationController

  def event
    event = Event.find_by_code(params[:event_code])

    participant = event.participants.find_by_user_id(current_user.id)
    if participant
      participant.destroy
    else
      event.participants.create!(user: current_user)
    end

    redirect_back fallback_location: root_url
  end
end
