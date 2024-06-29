# frozen_string_literal: true

class ParticipantsController < ApplicationController
  def event
    event = Event.by_link(params[:event_code])

    redirect_to root_url and return if event.nil?

    participant = event.participants.find_by(user_id: current_user.id)

    if participant
      participant.destroy
    else
      event.add_participant(current_user, public: params[:publika] == "jes")
    end

    redirect_to event_url(code: event.ligilo)
  end
end
