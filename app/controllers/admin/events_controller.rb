# frozen_string_literal: true

module Admin
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @events = Event.includes(:user).order(date_start: :desc)
    end

    def deleted
      @events = Event.deleted
    end

    def recover
      event = Event.deleted.find_by(code: params[:event_code])
      event.undelete!
      redirect_to event_path(event.code), flash: { success: 'Evento sukcesi restaŭrata' }
    end
  end
end
