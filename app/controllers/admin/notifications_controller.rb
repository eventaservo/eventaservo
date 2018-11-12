# frozen_string_literal: true

module Admin
  class NotificationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def index
      @recipients = NotificationList.includes(:country).order('countries.name, email').all
    end
  end
end
